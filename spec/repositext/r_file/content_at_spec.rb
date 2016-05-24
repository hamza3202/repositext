require_relative '../../helper'

class Repositext
  class RFile
    describe ContentAt do
      let(:contents) { "# title\n\nparagraph 1" }
      let(:language) { Language::English.new }
      let(:filename) { '/content/57/eng0103-1234.at' }
      let(:default_rfile) { RFile::ContentAt.new(contents, language, filename) }

      describe '#compute_similarity_with_corresponding_primary_file' do
        # TODO
      end

      describe '#corresponding_subtitle_markers_csv_file' do
        # TODO
      end

      describe '#corresponding_subtitle_markers_csv_filename' do
        it 'handles the default case' do
          default_rfile.corresponding_subtitle_markers_csv_filename.must_equal(
            '/content/57/eng0103-1234.subtitle_markers.csv'
          )
        end
      end

      describe '#has_subtitles?' do
        it 'handles the default case' do
          default_rfile.has_subtitles?.must_equal(false)
        end
      end

      describe '#kramdown_doc' do
        it 'handles the default case' do
          default_rfile.kramdown_doc.to_html.must_equal("<h1 id=\"title\">title</h1>\n\n<p>paragraph 1</p>\n")
        end
      end

      describe '#plain_text_contents' do
        it 'handles the default case' do
          default_rfile.plain_text_contents({}).must_equal("title\nparagraph 1")
        end
      end

      describe '#subtitles' do
        it 'handles the default case' do
          default_rfile.subtitles.must_equal([])
        end
      end
    end
  end
end