require_relative '../../../helper'

class Repositext
  class Process
    class Fix

      describe AddInitialPersistentSubtitleIds do

        let(:stm_csv_contents) {
          [
            'relativeMS	samples	charLength',
            '0	0	94',
            '1	10	95',
            '2	20	96',
            '',
          ].join("\n")
        }
        let(:content_at_contents) {
          [
            '^^^ {: .rid #rid-63480009}',
            '',
            '# heading',
            '',
            '@word1 @word2 @word3',
            '',
          ].join("\n")
        }
        let(:language) { Language::English.new }
        let(:stm_csv_file) { RFile::SubtitleMarkersCsv.new(stm_csv_contents, language, 'filename') }
        let(:content_at_file) {
          get_r_file(contents: content_at_contents, language: language)
        }
        let(:stids_inventory_file) {
          FileLikeStringIO.new('_path', "abcd\nefgh\n", 'r+')
        }
        let(:fixer) {
          AddInitialPersistentSubtitleIds.new(
            stm_csv_file,
            content_at_file,
            stids_inventory_file
          )
        }

        describe '#fix' do

          it 'handles default data' do
            fixer.fix.result.gsub(
              /\t[^\t]{7}\t63480009$/, "\tspid\t63480009"
            ).must_equal(
              [
                "relativeMS\tsamples\tcharLength\tpersistentId\trecordId",
                "0\t0\t94\tspid\t63480009",
                "1\t10\t95\tspid\t63480009",
                "2\t20\t96\tspid\t63480009\n",
              ].join("\n")
            )
          end

        end

        describe '#compute_record_id_mappings' do

          it 'handles default data' do
            r = fixer.send(:compute_record_id_mappings, content_at_contents)
            r.must_equal(["63480009", "63480009", "63480009"])
          end

          [
            [
              'Two records',
              [
                '^^^ {: .rid #rid-63480009}',
                '',
                '# heading',
                '',
                '@word1 @word2 @word3',
                '',
                '^^^ {: .rid #rid-63480019}',
                '',
                '@word4 @word5 @word6',
                '',
              ].join("\n"),
              ["63480009", "63480009", "63480009", "63480019", "63480019", "63480019"]
            ],
            [
              'Record IDs with letters',
              [
                '^^^ {: .rid #rid-6348B009}',
                '',
                '# heading',
                '',
                '@word1 @word2 @word3',
                '',
                '^^^ {: .rid #rid-6348C019}',
                '',
                '@word4 @word5 @word6',
                '',
              ].join("\n"),
              ["6348B009", "6348B009", "6348B009", "6348C019", "6348C019", "6348C019"]
            ],
            [
              'Empty file',
              [
                '',
              ].join("\n"),
              []
            ],
          ].each do |desc, content_at, xpect|

            it "handles #{ desc }" do
              r = fixer.send(:compute_record_id_mappings, content_at)
              r.must_equal(xpect)
            end

          end

        end

      end

    end
  end
end
