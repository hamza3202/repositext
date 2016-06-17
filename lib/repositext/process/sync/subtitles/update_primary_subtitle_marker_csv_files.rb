# encoding UTF-8
class Repositext
  class Process
    class Sync
      class Subtitles
        module UpdatePrimarySubtitleMarkerCsvFiles

          extend ActiveSupport::Concern

          # Updates STM CSV files for all of repository's content_at files that
          # require subtitle synchronization.
          # Merges the following to update STM CSV files:
          #  * Existing STIDS and record ids from existing STM CSV file
          #  * New time slices from subtitle import marker files
          #  * Updates to subtitles from subtitle operations
          # @param repo_root_dir [String]
          # @param language [Repositext::Language] used to instantiate content AT files
          # @param st_ops_for_repo [Repositext::Subtitle::OperationsForRepository]
          # @return [True]
          def update_primary_subtitle_marker_csv_files(repo_root_dir, content_type, st_ops_for_repo)
            synced_content_at_files = RFile::ContentAt.find_all(
              repo_root_dir,
              content_type
            )
            synced_content_at_files.each do |content_at_file|
              old_stids, new_time_slices, st_ops_for_file = extract_subtitle_sync_input_data(
                content_at_file,
                st_ops_for_repo
              )
              new_char_lengths = compute_new_char_lengths(content_at_file)

              # Only process files that have salient operations
              next  if st_ops_for_file.nil?

              validate_subtitle_sync_input_data(
                content_at_file,
                old_stids,
                new_time_slices,
                st_ops_for_file
              )
              new_subtitles_data = compute_new_subtitle_data(
                old_stids,
                new_time_slices,
                new_char_lengths,
                st_ops_for_file
              )
              update_stm_csv_file(
                content_at_file.corresponding_subtitle_markers_csv_file,
                new_subtitles_data
              )
            end
            true
          end

        private

          # Computes new subtitle char_lengths for all subtitles in content_at.
          # @param content_at_file [RFile::ContentAt] needs to be at toGitCommit
          # @return [Array<Integer>]
          def compute_new_char_lengths(content_at_file)
            Repositext::Utils::SubtitleMarkTools.extract_captions(
              content_at_file.contents
            ).map { |e| e[:char_length] }
          end

          # Extracts old_stids, new_time_slices, st_ops_for_file for content_at_file
          # and from st_ops_for_repo. Returns empty arrays if no st_ops exist for file.
          # @param content_at_file [RFile::ContentAt]
          # @param st_ops_for_repo [Repositext::Subtitle::OperationsForRepository]
          # @return [Array] with the following elements:
          #     * old_stids <Array>
          #     * new_time_slices <Array>
          #     * st_ops_for_file <Subtitle::OperationsForFile, Nil>
          def extract_subtitle_sync_input_data(content_at_file, st_ops_for_repo)
            # st_ops: extract from ST OPs for Repo
            content_at_product_identity_id = content_at_file.extract_product_identity_id
            st_ops_for_file = st_ops_for_repo.operations_for_files.detect { |e|
              content_at_product_identity_id == e.product_identity_id
            }
            # Return blank values if no st_ops are found for file
            return [[],[],nil]  if st_ops_for_file.nil?

            # old_stids: extract STIDs and record_ids from corresponding STM CSV file
            old_stids = []
            corr_stm_csv_file = content_at_file.corresponding_subtitle_markers_csv_file
            corr_stm_csv_file.each_row { |e|
              old_stids << { persistent_id: e['persistentId'], record_id: e['recordId'] }
            }
            # new_time_slices: extract time_slices from corresponding_subtitle_import_markers_file
            new_time_slices = []
            corr_st_import_markers_file = content_at_file.corresponding_subtitle_import_markers_file
            if corr_st_import_markers_file.nil?
              # no corresponding subtitle import markers file exists.
              if !st_ops_for_file.adds_or_removes_subtitles?
                # File only contains subtitle moves (some of which may be false
                # positives and be just content changes.
                # Use existing time slices from STM CSV file.
                corr_stm_csv_file.each_row { |e|
                  new_time_slices << { relative_milliseconds: e['relativeMS'], samples: e['samples'] }
                }
              else
                raise "no subtitle import file for #{ content_at_file.filename }"
              end
            else
              # Import file exists, grab updated time slices from there
              corr_st_import_markers_file.each_row { |e|
                new_time_slices << { relative_milliseconds: e['relativeMS'], samples: e['samples'] }
              }
            end
            [old_stids, new_time_slices, st_ops_for_file]
          end

          # Raises an exception if any of the input data is not valid
          # @param content_at_file [RFile::ContentAt]
          # @param old_stids [Array<Hash>]
          # @param new_time_slices [Array<Hash>]
          # @param st_ops_for_file [Subtitle::OperationsForFile]
          def validate_subtitle_sync_input_data(content_at_file, old_stids, new_time_slices, st_ops_for_file)
            # Validate that old and new subtitle counts are consistent with operations
            st_ops_count_delta = st_ops_for_file.subtitles_count_delta
            if old_stids.length + st_ops_count_delta != new_time_slices.length
puts "added stids:"
ap st_ops_for_file.instance_variable_get('@added_stids')
puts "deleted stids:"
ap st_ops_for_file.instance_variable_get('@deleted_stids')
ap st_ops_for_file
              raise InvalidInputDataError.new(
                [
                  "Subtitle count mismatch:",
                  "existing STM CSV file contains #{ old_stids.length } subtitles,",
                  "subtitle ops changed count by #{ st_ops_count_delta }",
                  "new subtitle import files contain #{ new_time_slices.length } subtitles",
                  "for file #{ content_at_file.filename }",
                ].join(' ')
              )
            end
          end

          # Returns updated subtitles data
          # @param old_stids [Array<Hash>]
          # @param new_time_slices [Array<Hash>]
          # @param new_char_lengths [Array<Integer>] mapped to new_time_slices
          # @param st_ops_for_file [Subtitle::OperationsForFile]
          # @return [Array<Hash>] with one key for each STM CSV file column:
          #         [
          #           {
          #             relative_milliseconds: 123,
          #             samples: 123,
          #             char_length: 123,
          #             persistent_id: 123,
          #             record_id: 123,
          #           }
          #         ]
          def compute_new_subtitle_data(old_stids, new_time_slices, new_char_lengths, st_ops_for_file)
            new_sts = st_ops_for_file.apply_to(old_stids)
# TODO: We need to replace the tmp-stids in st_ops with the newly generated persistent ids, write them back to file.
            # what about record ids? Do we need to re-detect them?
                # if previous and following record_id are identical use that.
                # may need to detect at boundaries.
            # Merge new time slices and char_lengths
            new_sts.each_with_index { |new_st, idx|
              new_st.merge!(new_time_slices[idx])
              new_st[:char_length] = new_char_lengths[idx]
            }
            # Assign record ids to inserted subtitles
            # Since every paragraph has to start with a subtitle, we can assume
            # that any added subtitles are after an existing subtitle.
# TODO: move this out of this method, pass new_record_ids as argument to method.
            if new_sts.first[:record_id].nil?
              raise "Handle this: #{ new_sts.inspect }"
            end
            new_sts.each_cons(2) { |previous_st, st|
              if st[:record_id].nil?
                if previous_st[:record_id].nil?
                  raise "Handle this: #{ new_sts.inspect }"
                end
                st[:record_id] = previous_st[:record_id]
              end
            }
            new_sts
          end

          # Updates stm_csv_file with new_subtitles_data
          # @param stm_csv_file [RFile::SubtitleMarkersCsv]
          # @param new_subtitles_data []
          def update_stm_csv_file(stm_csv_file, new_subtitles_data)
            stm_csv_file.update!(new_subtitles_data)
          end

        end
      end
    end
  end
end
