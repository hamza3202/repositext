# -*- coding: utf-8 -*-

# Converts tree to subtitle tagging
module Kramdown
  module Converter
    class SubtitleTagging < Subtitle

    protected

      def gap_mark_output
        # gap_marks are rendered for subtitle_tagging output
        '%'
      end

    end
  end
end
