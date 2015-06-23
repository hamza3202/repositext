class Repositext
  class Validation
    class SubtitleMarkNoSignificantChanges < Validation

      # Specifies validations to run for files in the /content directory
      def run_list

        # File pairs

        # Validate that there are no significant changes to subtitle_mark positions.
        # Define proc that computes subtitle_mark_csv filename from content_at filename
        stm_csv_file_name_proc = lambda { |input_filename, file_specs|
          Repositext::Utils::CorrespondingPrimaryFileFinder.find(
            filename: input_filename,
            language_code_3_chars: @options['primary_repo_transform_params'][:language_code_3_chars],
            rtfile_dir: @options['primary_repo_transform_params'][:rtfile_dir],
            relative_path_to_primary_repo: @options['primary_repo_transform_params'][:relative_path_to_primary_repo],
            primary_repo_lang_code: @options['primary_repo_transform_params'][:primary_repo_lang_code]
          ).gsub( # update file extension
            /\.at\z/,
            '.subtitle_markers.csv'
          )
        }
        # Run pairwise validation
        validate_file_pairs(:content_at_files, stm_csv_file_name_proc) do |ca, stm_csv|
          # skip if subtitle_markers CSV file doesn't exist
          next  if !File.exists?(stm_csv)
          Validator::SubtitleMarkNoSignificantChanges.new(
            [File.open(ca), File.open(stm_csv)], @logger, @reporter, @options
          ).run
        end
      end

    end
  end
end