class Repositext
  class Validation
    # Validation to run after a Folio XML import.
    class FolioXmlPostImport < Validation

      # Specifies validations to run related to Folio Xml post import.
      def run_list
        config = @options['config']
        validate_files(:imported_repositext_files) do |text_file|
          Validator::Utf8Encoding.new(text_file, @logger, @reporter, @options).run
        end
        validate_files(:imported_at_files) do |content_at_file|
          @options['run_options'] << 'kramdown_syntax_at-all_elements_are_inside_record_mark'
          Validator::KramdownSyntaxAt.new(
            content_at_file,
            @logger,
            @reporter,
            @options.merge(
              "validator_invalid_gap_mark_regex" => config.setting(:validator_invalid_gap_mark_regex),
              "validator_invalid_subtitle_mark_regex" => config.setting(:validator_invalid_subtitle_mark_regex)
            )
          ).run
        end
      end

    end
  end
end
