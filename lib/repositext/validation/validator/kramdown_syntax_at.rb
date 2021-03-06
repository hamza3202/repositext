class Repositext
  class Validation
    class Validator
      # Validates a kramdown AT string's valid syntax.
      class KramdownSyntaxAt < KramdownSyntax

        def self.whitelisted_kramdown_features
          KramdownSyntaxPt.whitelisted_kramdown_features + \
          [
            :gap_mark,
            :record_mark,
            :subtitle_mark,
          ]
        end

        def self.whitelisted_class_names
          KramdownSyntaxPt.whitelisted_class_names
        end

        # Returns an array of regexes that will detect invalid characters.
        def self.invalid_character_detectors
          # '%' and '@' are allowed in AT files, so we don't add them to list
          # of invalid characters.
          Repositext::Validation::Config::INVALID_CHARACTER_REGEXES
        end

        def run
          content_at_file = @file_to_validate
          errors, warnings = [], []

          outcome = valid_kramdown_syntax?(content_at_file)
          errors += outcome.errors
          warnings += outcome.warnings

          outcome = valid_syntax_at?(content_at_file)
          errors += outcome.errors
          warnings += outcome.warnings

          log_and_report_validation_step(errors, warnings)
        end

        # AT specific syntax validation
        # @param content_at_file [RFile::ContentAt]
        # @return [Outcome]
        def valid_syntax_at?(content_at_file)
          errors = []
          warnings = []

          validate_record_mark_syntax(content_at_file, errors, warnings)
          validate_escaped_character_syntax(content_at_file, errors, warnings)

          Outcome.new(errors.empty?, nil, [], errors, warnings)
        end

        # Implement AT specific validation callback when walking the tree.
        # @param content_at_file [RFile::ContentAt] the file to validate
        # @param el [Kramdown::Element]
        # @param el_stack [Array<Kramdown::Element] stack of ancestor elements,
        #   immediate parent is last element in array.
        # @param errors [Array] collector for errors
        # @param warnings [Array] collector for warnings
        def validation_hook_on_element(content_at_file, el, el_stack, errors, warnings)
          case el.type
          when :em
            validate_no_single_punctuation_or_whitespace_char_formatting(
              content_at_file, el, el_stack, errors, warnings
            )
          when :p
            validate_element_p(
              content_at_file, el, el_stack, errors, warnings
            )
          when :record_mark
            validate_element_record_mark(
              content_at_file, el, el_stack, errors, warnings
            )
          when :root
            validate_element_root(
              content_at_file, el, el_stack, errors, warnings
            )
          when :strong
            validate_no_single_punctuation_or_whitespace_char_formatting(
              content_at_file, el, el_stack, errors, warnings
            )
          when :text
            validate_element_text(
              content_at_file, el, el_stack, errors, warnings
            )
          end
        end

      protected

        # @param content_at_file [RFile::ContentAt]
        # @param errors [Array] collector for errors
        # @param warnings [Array] collector for warnings
        def validate_record_mark_syntax(content_at_file, errors, warnings)
          # Record_marks_have to be preceded by a blank line.
          # The only exception is the first record_mark in each file.
          str_sc = Kramdown::Utils::StringScanner.new(content_at_file.contents)
          str_sc.skip_until(/\A\^\^\^/) # skip the first record_mark at beginning of source if it exists
          while !str_sc.eos? do
            if (match = str_sc.scan_until(/(?<!\n\n)\^\^\^/))
              errors << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: str_sc.current_line_number,
                  context: match[-40..-1].inspect,
                },
                [':record_mark not preceded by blank line']
              )
            else
              break
            end
          end

          # Make sure we have no :record_marks with no text between them
          str_sc.reset
          while !str_sc.eos? do
            match = str_sc.scan_until(
              /
                \^\^\^ # record mark
                [^\n\^]* # optional IAL on same line as record mark
                \s* # nothing but optional whitespace
                \^\^\^ # another record mark
              /x
            )
            if match
              position_of_previous_record_mark = match.rindex('^^^', -4) || 0
              relevant_match_fragment = match[position_of_previous_record_mark..-1].inspect
              relevant_match_fragment.gsub!(/^\"/, '') # Remove leading double quotes (from inspect)
              relevant_match_fragment.gsub!(/\"$/, '') # Remove trailing double quotes (from inspect)
              errors << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: str_sc.current_line_number,
                  context: relevant_match_fragment,
                },
                ['Consecutive :record_marks with no text inbetween']
              )
            else
              break
            end
          end

          # All record_marks have to be followed by exactly two newlines
          str_sc.reset
          while !str_sc.eos? do
            match = str_sc.scan_until(
              /
                \^\^\^ # record mark
                [^\n\^]* # optional IAL on same line as record mark
                \n # end of line
                (?!\n[^\n]) # followed by anything other than exactly one more newline
              /x
            )
            if match
              context_len = [match.size, 40].min
              errors << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: str_sc.current_line_number,
                  context: match[-context_len..-1],
                },
                [':record_mark not followed by two newlines']
              )
            else
              break
            end
          end
        end

        def validate_element_p(content_at_file, el, el_stack, errors, warnings)
          el_descendants = el.descendants
          if(
            el.has_class?('normal') &&
            el_descendants.any? { |el_desc| el_desc.has_class?('pn') }
          )
            # p.normal contains a paragraph number
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: el.options[:location],
                context: el.element_summary(0, max_value_length: 0),
              },
              ['p.normal contains a paragraph number']
            )
          elsif(
            el.has_class?('normal_pn') &&
            el_descendants.none? { |el_desc| el_desc.has_class?('pn') }
          )
            # p.normal_pn does not contain a paragraph number
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: el.options[:location],
                context: el.element_summary(0, max_value_length: 0),
              },
              ['p.normal_pn does not contain a paragraph number']
            )
          elsif(
            !el.has_class?('normal_pn') &&
            el_descendants.any? { |el_desc| el_desc.has_class?('pn') }
          )
            # para with class other than .normal_pn contains a paragraph number
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: el.options[:location],
                context: el.element_summary(0, max_value_length: 0),
              },
              ['para with class other than .normal_pn contains a paragraph number']
            )
          end
        end

        def validate_element_record_mark(content_at_file, el, el_stack, errors, warnings)
          # Validates that kpns are monotonically increasing and consecutive
          if el.attr['kpn']
            l_kpn = el.attr['kpn'].to_i
            if @kpn_tracker.nil?
              # First kpn, initialize tracker
              @kpn_tracker = l_kpn
            else
              # Subsequent KPN
              if(
                (l_kpn != @kpn_tracker + 1) && \
                !(
                  (@file_to_validate.filename.index('eng60-0515m_0663') && l_kpn == 9) || # exception 1
                  (@file_to_validate.filename.index('eng63-0318_0943') && l_kpn == 181) # exception 2
                )
              )
                warnings << Reportable.error(
                  {
                    filename: content_at_file.filename,
                    line: el.options[:location],
                    context: "Previous KPN: #{ @kpn_tracker.inspect }, Current KPN: #{ l_kpn.inspect }",
                  },
                  [
                    'Invalid KPN',
                    "KPN has unexpected value: #{ l_kpn.inspect }",
                  ]
                )
              end
              @kpn_tracker = l_kpn
            end
          end
          # Validates that record ids are formatted correctly
          l_id = el.attr['id']
          if '' == l_id.to_s.strip
            # Record ID is missing
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: el.options[:location],
              },
              [
                'Record ID is missing',
              ]
            )
          elsif l_id !~ /\Arid-[\dABC]{8}\z/ # matches "rid-55010139"
            # Invalid Record ID
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: el.options[:location],
              },
              [
                'Record ID is invalid',
                "Invalid record ID: #{ l_id.inspect }",
              ]
            )
          end

          # Validates that all p.song and p.song_break paragraphs are preceded by p.stanza,
          # p.song or p.song_break only. We assume that every p.song is a direct child of a
          # :record_mark
          non_blank_children = el.children.find_all { |e| :blank != e.type }
          first_child = non_blank_children.first
          if(first_child && :p == first_child.type && first_child.has_class?('song song_break'))
            # First :p in :record_mark is p.song or p.song_break
            errors << Reportable.error(
              {
                filename: content_at_file.filename,
                line: first_child.options[:location],
                context: first_child.element_summary(0, max_value_length: 0),
              },
              [
                'p.song not preceded by p.stanza or p.song',
                "Preceded by #{ el.element_summary(0, max_value_length: 0) }",
              ]
            )
          end
          non_blank_children.each_cons(2) { |first_el, second_el|
            if(
              (:p == second_el.type && second_el.has_class?('song song_break')) &&
              (:p == first_el.type && !first_el.has_class?('stanza song song_break'))
            )
              # subsequent p.song preceded by something other than p.stanza or p.song
              errors << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: second_el.options[:location],
                  context: second_el.element_summary(0, max_value_length: 0),
                },
                [
                  'p.song not preceded by p.stanza or p.song',
                  "Preceded by #{ first_el.element_summary(0, max_value_length: 0) }",
                ]
              )
            end
          }
        end

        def validate_element_root(content_at_file, el, el_stack, errors, warnings)
          if @options['run_options'].include?('kramdown_syntax_at-all_elements_are_inside_record_mark')
            # Validates that every element is contained inside a record_mark.
            # In other words, the root element may only contain elements of type :record_mark
            el.children.each do |child|
              if(:record_mark != child.type)
                warnings << Reportable.error(
                  {
                    filename: content_at_file.filename,
                    line: el.options[:location],
                    context: el.element_summary(0, max_value_length: 0),
                  },
                  [
                    'Element outside of :record_mark',
                    "Element is not contained in a :record_mark",
                  ]
                )
              end
            end
          end
        end

        # Call with em and strong els. Validates that no single punctuation or
        # whitespace characters are formatted.
        def validate_no_single_punctuation_or_whitespace_char_formatting(content_at_file, el, el_stack, errors, warnings)
          # ImplementationTag #punctuation_characters
          punctuation_chars = %(!()+,-./:;?[]—‘’“”…\u2011\u00A0\u202F\uFEFF\u2028)
          if(1 == (pt = el.to_plain_text).length) && pt =~ /\A[\s\n#{ Regexp.escape(punctuation_chars) }]\z/
            # Single punctuation or whitespace character
            report_error = nil
            # Handle exceptions:
            if(
              (parent_p_el = el_stack.reverse.detect { |a_el| :p == a_el.type }) &&
              parent_p_el.has_class?('scr')
            )
              # Exception: Inside .scr paragraph: Only check for space
              report_error = [' '].include?(pt)
            elsif el.has_class?('line_break')
              # *.*{: .line_break} is legitimate, don't report as error
              report_error = false
            else
              report_error = true
            end

            if report_error
              errors << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: el.options[:location],
                  context: el.element_summary(0, max_value_length: 0),
                },
                [
                  'Single formatted punctuation or whitespace character',
                  "Type: #{ el.type }, Inner text: #{ pt.inspect }"
                ]
              )
            end
          end
        end

        def validate_element_text(content_at_file, el, el_stack, errors, warnings)
          if @options['run_options'].include?('kramdown_syntax_at-no_underscore_or_caret')
            # No underscores, carets or equal signs allowed in content AT (inner texts)
            # We have to check this here where we have access to the inner text,
            # rather than in #validate_character_inventory, since e.g.,
            # class attrs may contain legitimate underscores.
            if(el.value =~ /[\_\^\=]/)
              warnings << Reportable.error(
                {
                  filename: content_at_file.filename,
                  line: el.options[:location],
                  context: el.element_summary(0, max_value_length: 0),
                },
                [
                  'Invalid underscore, caret, or equal sign in text element.',
                  "Text contents: #{ el.value.inspect }"
                ]
              )
            end
          end
        end

      end
    end
  end
end
