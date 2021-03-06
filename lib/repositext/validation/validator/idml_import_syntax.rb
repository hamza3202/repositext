class Repositext
  class Validation
    class Validator
      # Validates correct syntax of IDML import file.
      class IdmlImportSyntax < Validator

        def run
          idml_file = @file_to_validate
          outcome = valid_idml_syntax?(idml_file)
          log_and_report_validation_step(outcome.errors, outcome.warnings)
        end

      protected

        def valid_idml_syntax?(idml_file)
          errors = []
          warnings = []
          idml_parser = @options['idml_validation_parser_class'].new(idml_file.contents)

          validate_character_inventory(idml_parser, errors, warnings)
          validate_idml_story_source(idml_parser, errors, warnings)
          validate_parse_tree(idml_parser, errors, warnings)

          Outcome.new(errors.empty?, nil, [], errors, warnings)
        end

        # @param [Kramdown::Parser::VgrIdmlValidation] idml_parser should be a
        #      validating parser like Kramdown::Parser::VgrIdmlStoryValidation
        # @param [Array] errors collector for errors
        # @param [Array] warnings collector for warnings
        def validate_idml_story_source(idml_parser, errors, warnings)
          # idml_story = idml_parser.stories_to_import.first
          # idml_story_name = idml_story.name
          # idml_story_source = idml_story.body
          # Was used to check for invalid characters, now moved to
          # `validate_character_inventory`
          # We may not need this method any more.
        end

        # Delegates validation to idml_parser. That parser collects reportables
        # into errors and warnings.
        # @param [Kramdown::Parser::VgrIdmlValidation] idml_parser
        # @param [Array] errors collector for errors
        # @param [Array] warnings collector for warnings
        def validate_parse_tree(idml_parser, errors, warnings)
          idml_parser.parse(
            idml_parser.stories_to_import,
            {
              'validation_errors' => errors,
              'validation_warnings' => warnings,
              'validation_file_descriptor' => @file_to_validate.filename,
              'validation_logger' => @logger,
            }
          )
        end

        # @param [Kramdown::Parser::VgrIdmlValidation] idml_parser
        # @param [Array] errors collector for errors
        # @param [Array] warnings collector for warnings
        def validate_character_inventory(idml_parser, errors, warnings)
          idml_story = idml_parser.stories_to_import.first
          idml_story_name = idml_story.name
          idml_story_source = idml_story.body
          # Detect invalid characters
          str_sc = Kramdown::Utils::StringScanner.new(idml_story_source)
          while !str_sc.eos? do
            if (match = str_sc.scan_until(
              Regexp.union(Repositext::Validation::Config::INVALID_CHARACTER_REGEXES)
            ))
              errors << Reportable.error(
                {
                  filename: @file_to_validate.filename,
                  line: str_sc.current_line_number,
                  context: sprintf("story %5s", idml_story_name),
                },
                ['Invalid character', sprintf('U+%04X', match[-1].codepoints.first)]
              )
            else
              break
            end
          end
          # Build character inventory
          if 'debug' == @logger.level
            chars = Hash.new(0)
            ignored_chars = [0x30..0x39, 0x41..0x5A, 0x61..0x7A]
            idml_story_source.codepoints.each { |cp|
              chars[cp] += 1  unless ignored_chars.any? { |r| r.include?(cp) }
            }
            chars = chars.sort_by { |k,v|
              k
            }.map { |(code,count)|
              sprintf("U+%04x  #{ code.chr('UTF-8') }  %5d", code, count)
            }
            @reporter.add_stat(
              Reportable.stat(
                { filename: @file_to_validate.filename },
                ['Character Histogram', chars]
              )
            )
          end
        end

      end
    end
  end
end
