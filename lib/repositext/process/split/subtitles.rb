class Repositext
  class Process
    class Split
      # Splits a foreign_file's subtitles based on subtitles in corresponding
      # primary_file. Returns new contents of foreign content AT file as String.
      #
      # Expects both primary and foreign plain_text_for_st_autosplit files to
      # already exist.
      #
      # # Notes
      #
      # The sentence alignment will not always be perfect. In some cases a
      # primary sentence gets split into two foreign sentences, or two primary
      # sentences may get merged into a single foreign sentence. It may even
      # occur that two sentences from different paragraphs get merged.
      class Subtitles

        include AlignSentences
        include TransferStsFromFAlignedSentences2FPlainText
        include TransferStsFromFPlainText2ForeignContentAt
        include TransferStsFromPAlignedSentences2FAlignedSentences
        include TransferStsFromPPlainText2PAlignedSentences

        # @param p_content_at_file [Repositext::RFile::ContentAt] the primary content AT file
        # @param f_content_at_file [Repositext::RFile::ContentAt] the foreign content AT file
        # @param options [Hash] :remove_existing_sts will remove subtitle_marks
        #   that alread exist in f_content_at_file.
        def initialize(p_content_at_file, f_content_at_file, options={})
          @options = {
            remove_existing_sts: false
          }.merge(options)

          @p_content_at_file = p_content_at_file
          @f_content_at_file = f_content_at_file
        end

        # @return [Outcome] with new foreign content AT file contents as result.
        def split
          # Align sentences in input files
          as_o = align_sentences(@p_content_at_file, @f_content_at_file)
          return as_o  if !as_o.success?
          asp = as_o.result # Array of arrays with p and f sentences (or nil)

          # Transfer subtitles from primary plain text to primary aligned sentences
          p_pt = @p_content_at_file.plain_text_for_st_autosplit_contents(
            st_autosplit_context: :for_st_transfer_primary
          )
          tsf_p_pt2p_as_o = transfer_sts_from_p_plain_text_2_p_aligned_sentences(
            p_pt, asp
          )
          return tsf_p_pt2p_as_o  if !tsf_p_pt2p_as_o.success?
          asp_w_p_st = tsf_p_pt2p_as_o.result

          # Transfer subtitles from primary to foreign aligned sentences
          tsf_p_as2f_as_o = transfer_sts_from_p_aligned_sentences_2_f_aligned_sentences(
            asp_w_p_st
          )
          return tsf_p_as2f_as_o  if !tsf_p_as2f_as_o.success?

          # Transfer subtitles from foreign sentences to foreign plain text
          f_s_w_st, f_s_confs = tsf_p_as2f_as_o.result
          f_pt = @f_content_at_file.plain_text_for_st_autosplit_contents(
            st_autosplit_context: :for_st_transfer_foreign
          )
          tsf_f_as2f_pt_o = transfer_sts_from_f_aligned_sentences_2_f_plain_text(
            f_s_w_st,
            f_pt,
            f_s_confs,
            @options[:remove_existing_sts]
          )
          return tsf_f_as2f_pt_o  if !tsf_f_as2f_pt_o.success?

          # Transfer subtitles from foreign plain text to foreign content AT
          f_pt, f_st_confs = tsf_f_as2f_pt_o.result
          f_cat = @f_content_at_file.contents
          o = transfer_sts_from_f_plain_text_2_f_content_at(
            f_pt,
            f_cat,
            f_st_confs,
            @options[:remove_existing_sts]
          )
        end

        def debug
          true
        end
      end
    end
  end
end
