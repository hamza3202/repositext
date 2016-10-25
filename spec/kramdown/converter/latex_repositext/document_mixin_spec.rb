require_relative '../../../helper'

module Kramdown
  module Converter
    class LatexRepositext
      # We test it as part of LatexRepositextPlain (includes DocumentMixin)
      describe DocumentMixin do

        describe "#compute_truncated_title" do
          [
            [
              "No truncation required",
              "word word",
              "\\emph{word} word",
              20,
              3,
              "\\emph{word} word"
            ],
            [
              "Simple truncation with min word length",
              "word1 word2 word3 word4 word5",
              "\\emph{word1 word2 word3 word4 word5}",
              20,
              3,
              "\\emph{word1 word2 word3…}"
            ],
            [
              "Truncation with nested latex commands, before nested",
              "word1 word2 word3 word4 word5",
              "\\emph{word1 word2 word3 \\textscale{0.7}{word4 word5}}",
              20,
              3,
              "\\emph{word1 word2 word3…\\textscale{0.7}{}}"
            ],
            [
              "Truncation with nested latex commands, inside nested",
              "word1 word2 word3 word4 word5",
              "\\emph{word1 word2 \\textscale{0.7}{word3 word4 word5}}",
              20,
              3,
              "\\emph{word1 word2 \\textscale{0.7}{word3…}}"
            ],
            [
              "Truncation with adjacent latex commands",
              "word1 word2 word3 word4 word5",
              "\\emph{word1 word2} \\emph{word3 word4 word5}",
              20,
              3,
              "\\emph{word1 word2} \\emph{word3…}"
            ],
            [
              "Truncation with large number of truncated latex commands",
              "Word Word Word Word, Word Word Word Word Word Word Word Word Word Word Word Word",
              "\\emph{W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em}, W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em}}",
              20,
              3,
              "\\emph{W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em}…\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}}"
            ],
            [
              "Truncation with multiple latex commands",
              "A Word Wording Word \nWord Word Word Word",
              "\\emph{A W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{0.1em}{ORDING}{-0.3em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} \\linebreak\nW\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em}}",
              20,
              3,
              "\\emph{A W\\RtSmCapsEmulation{none}{ORD}{-0.1em} W\\RtSmCapsEmulation{0.1em}{ORDING}{-0.3em} W\\RtSmCapsEmulation{none}{ORD}{-0.1em}…\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}\\RtSmCapsEmulation{none}{}{-0.1em}}"
            ],
            [
              "Simple truncation without min word length",
              "word1 word2 word3 word4 word5",
              "\\emph{word1 word2 word3 word4 word5}",
              20,
              0,
              "\\emph{word1 word2 word3 w…}"
            ],
          ].each do |desc, title_plain_text, title_latex, max_len, min_length_of_last_word, xpect|
            it "truncates #{ desc }" do
              converter = LatexRepositextPlain.send(:new, '_', {})
              converter.send(
                :compute_truncated_title,
                title_plain_text,
                title_latex,
                max_len,
                min_length_of_last_word
              ).must_equal(xpect)
            end
          end
        end
      end
    end
  end
end
