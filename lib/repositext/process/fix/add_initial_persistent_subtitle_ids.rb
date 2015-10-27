class Repositext
  class Process
    class Fix
      class AddInitialPersistentSubtitleIds

        # @param stm_csv_file [Repositext::RFile]
        # @param content_at_file [Repositext::RFile]
        # @param spids_inventory_file [IO] file that contains the inventory of
        #          existing SPIDs.
        #          Typically located at /data/subtitle_persistent_ids.txt
        #          Must exist and be opened with mode "r+"
        def initialize(stm_csv_file, content_at_file, spids_inventory_file)
          raise ArgumentError.new("Invalid stm_csv_file: #{ stm_csv_file.inspect }")  unless stm_csv_file.is_a?(RFile)
          raise ArgumentError.new("Invalid content_at_file: #{ content_at_file.inspect }")  unless content_at_file.is_a?(RFile)
          @stm_csv_file = stm_csv_file
          @content_at_file = content_at_file
          @spids_inventory_file = spids_inventory_file
        end

        # Inserts two more columns into subtitle markers CSV file: persistentId and recordId
        # relativeMS  samples charLength
        # 0 0 47
        # ->
        # relativeMS  samples charLength persistentId recordId
        # 0 0 47  Ag57   63280005
        # @return [Outcome] with updated stm_csv_file contents as result
        def fix
          record_id_mappings = compute_record_id_mappings(@content_at_file.contents)
          subtitles = Subtitle::ExtractFromStmCsvFile.new(@stm_csv_file).extract
          num_subtitles = subtitles.length

          if record_id_mappings.length != num_subtitles
            raise(ArgumentError.new("Difference in subtitles count: CSV: #{ num_subtitles }, content AT: #{ record_id_mappings.length }"))
          end

          spids = Repositext::Subtitle::PersistentIdGenerator.new(
            @spids_inventory_file
          ).generate(
            num_subtitles
          )

          contents_with_spids_and_rids = [
            %w[relativeMS samples charLength persistentId recordId].join("\t")
          ] # initialize with CSV header row
          subtitles.each { |subtitle|
            # append spid and rid to all lines that start with a digit
            spid = spids.shift
            raise "Not enough spids!"  if spid.nil?
            rid = record_id_mappings.shift
            raise "Not enough rids!"  if rid.nil?
            contents_with_spids_and_rids << [
              subtitle.relative_milliseconds,
              subtitle.samples,
              subtitle.char_length,
              spid,
              rid
            ].join("\t")
          }
          Outcome.new(true, contents_with_spids_and_rids.join("\n"))
        end

      private

        # @param content_at [String]
        # @return [Array] with one entry for each subtitle, containing the
        #     corresponding record_id.
        def compute_record_id_mappings(content_at)
          content_at.split(/(?=^\^\^\^)/).map { |record|
            next nil  if !record =~ /\A\^\^\^/
            rid = record.match(/\A[^\n]+#rid-([[:alnum:]]+)/)[1]
            [rid] * record.count('@')
          }.compact.flatten
        end

      end
    end
  end
end



