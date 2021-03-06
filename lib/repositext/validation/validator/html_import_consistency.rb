class Repositext
  class Validation
    class Validator
      # Validates that the text contents in html_input_file match those of the
      # imported AT file.
      # Purpose: To make sure that the import worked correctly and nothing
      # was changed inadvertently.
      class HtmlImportConsistency < Validator

        class TextMismatchError < ::StandardError; end

        # Runs all validations for self
        def run
          # @file_to_validate is an array with the input_html and
          # html imported at files
          input_html_file, imported_at_file = @file_to_validate
          return Outcome.new(true, nil, [])  if input_html_file.filename.index('dut65-1127b_1142.html')
          outcome = contents_match?(
            input_html_file,
            imported_at_file
          )
          log_and_report_validation_step(outcome.errors, outcome.warnings)
        end

      private

        # Checks if contents match
        # @param input_html_file [RFile::Html]
        # @param html_imported_at_file [RFile::ContentAt]
        # @return [Outcome]
        def contents_match?(input_html_file, html_imported_at_file)

          # Since the kramdown parser is specified as module in Rtfile,
          # I can't use the standard kramdown API:
          # `doc = Kramdown::Document.new(contents, :input => 'kramdown_repositext')`
          # We have to patch a base Kramdown::Document with the root to be able
          # to convert it.
          root, _warnings = @options['kramdown_parser_class'].parse(html_imported_at_file.contents)
          doc = Kramdown::Document.new('')
          doc.root = root

          input_html = input_html_file.contents.gsub('&nbsp;', ' ') # remove all non-breaking spaces
          input_html.gsub!('H<span class="smallcaps">EERE</span>', 'Heere')
          input_html.gsub!('H<span class="smallcaps">EEREN</span>', 'Heeren')
          input_html.gsub!('H<span class="smallcaps">ERE</span>', 'Here')
          input_html.gsub!('H<span class="smallcaps">EREN</span>', 'Heren')
          input_html.gsub!('&#160;', ' ') # replace non-breaking spaces with regular spaces
          input_html.gsub!('&#173;', '') # remove discretionary hyphens


          html_doc = Nokogiri::HTML(input_html) { |cfg| cfg.noent }
          input_html_based_plain_text = html_doc.at_css('body').text
          input_html_based_plain_text.gsub!(/\r/, "\n") # normalize linebreaks
          input_html_based_plain_text.gsub!(/((?:^|\s)\d+[a-z]?)\.(?!\.)/, '\1') # remove periods from question numbers (and any number followed by period)
          input_html_based_plain_text.gsub!('*******', '') # remove simulated hr
          input_html_based_plain_text.gsub!(/\s/, ' ') # replace all whitespace with space
          input_html_based_plain_text.gsub!(/\s+/, ' ') # collapse runs of spaces
          input_html_based_plain_text.gsub!(/\s+\]/, ']') # remove space before closing brackets
          input_html_based_plain_text.gsub!('%', ' procent') # spell out percent instead of using '%' to avoid conflict with gap_marks
          input_html_based_plain_text.gsub!('‑', '')
          input_html_based_plain_text.gsub!('…', '...') # unfix elipses
          input_html_based_plain_text.strip!

          at_based_plain_text = doc.send(@options['plain_text_converter_method_name'])
          at_based_plain_text.gsub!(/((?:^|\s)\d+[a-z]?)\.(?!\.)/, '\1') # remove periods from question numbers (and any number followed by period)
          at_based_plain_text.gsub!(/\s/, ' ') # replace all whitespace with space
          at_based_plain_text.gsub!(/\s+/, ' ') # collapse runs of spaces
          at_based_plain_text.gsub!('…', '...') # unfix elipses
          at_based_plain_text.gsub!(/[“”]/, '"') # unfix typographic double quotes
          at_based_plain_text.gsub!(/[’‘]/, "'") # unfix single typographic quotes
          at_based_plain_text.strip!

          error_message = "Text mismatch between HTML source and AT from input_html in #{ input_html_file.filename }."
          diffs = Suspension::StringComparer.compare(input_html_based_plain_text, at_based_plain_text)
          non_whitespace_diffs = diffs.find_all { |e| ' ' != e[1] }

          if non_whitespace_diffs.empty?
            Outcome.new(true, nil)
          else
            # We want to terminate an import if the text is not consistent.
            # Normally we'd return a negative outcome (see below), but in this
            # case we raise an exception.
            # Outcome.new(
            #   false, nil, [],
            #   [
            #     Reportable.error(
            #       [@file_to_validate.last.filename], # subtitle/subtitle_tagging_import file
            #       [
            #         'Text mismatch between subtitle/subtitle_tagging_import and input_html:',
            #         non_whitespace_diffs.inspect
            #       ]
            #     )
            #   ]
            # )
            raise TextMismatchError.new(
              [
                error_message,
                "Cannot proceed with import. Please resolve text differences first:",
                non_whitespace_diffs.inspect
              ].join("\n")
            )
          end
        end

      end
    end
  end
end
