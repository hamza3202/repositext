#require 'ruby-prof'

# 3rd party libraries

# Selectively include ActiveSupport features we want
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/filters'

require 'alignment'
require 'awesome_print'
require 'diff/lcs'
require 'erb'
require 'find'
require 'json'
require 'kramdown'
require 'logging'
require 'needleman_wunsch_aligner'
require 'nokogiri'
require 'open3'
require 'ostruct'
require 'outcome'
require 'parallel'
require 'pp'
require 'pragmatic_segmenter'
require 'rugged'
require 'suspension'
require 'thor'
require 'unicode_utils/downcase'
require 'unicode_utils/upcase'
require 'zip'

# Establish namespace and class inheritance for Cli before we require nested
# classes. Otherwise we get a subclass mismatch error because Cli is initialized as
# standalone class (not inheriting from Thor)
class Repositext
  class Cli < Thor
  end
end

# repositext libraries

require 'patches/array'
require 'patches/nokogiri_xml_node'
require 'patches/string'
require 'recursive_data_hash'
require 'repositext/constants'

# The requires are grouped by levels of dependencies, where lower groups depend on
# higher level groups.

# Dependency boundary

require 'kramdown/converter/graphviz'
require 'kramdown/converter/html_doc'
require 'kramdown/converter/html_repositext'
require 'kramdown/converter/icml'
require 'kramdown/converter/idml_story'
require 'kramdown/converter/kramdown_repositext'
require 'kramdown/converter/latex_repositext'
require 'kramdown/converter/latex_repositext/document_mixin'
require 'kramdown/converter/latex_repositext/render_record_marks_mixin'
require 'kramdown/converter/latex_repositext/render_subtitle_and_gap_marks_mixin'
require 'kramdown/converter/paragraph_alignment_objects'
require 'kramdown/converter/paragraph_alignment_objects/block_element'
require 'kramdown/converter/plain_text'
require 'kramdown/converter/report_kramdown_element_classes_inventory'
require 'kramdown/converter/report_misaligned_question_paragraphs'
require 'kramdown/converter/subtitle'
require 'kramdown/element_rt'
require 'kramdown/mixins/adjacent_element_merger'
require 'kramdown/mixins/docx_import_post_processor'
require 'kramdown/mixins/import_whitespace_sanitizer'
require 'kramdown/mixins/nested_ems_processor'
require 'kramdown/mixins/raw_text_parser'
require 'kramdown/mixins/tmp_em_class_processor'
require 'kramdown/mixins/tree_cleaner'
require 'kramdown/mixins/whitespace_out_pusher'
require 'kramdown/parser/docx'
require 'kramdown/parser/folio'
require 'kramdown/parser/idml'
require 'kramdown/parser/idml_story'
require 'kramdown/parser/idml_story_validation'
require 'kramdown/parser/idml_validation'
require 'kramdown/parser/kramdown_repositext'
require 'kramdown/parser/kramdown_validation'
require 'kramdown/patch_element'
require 'kramdown/tree_structural_similarity'
require 'kramdown/tree_structure_extractor'
require 'repositext/entity'
require 'repositext/entity/subtitle_mark'
require 'repositext/entity/subtitle_mark/persistent_id_generator'
require 'repositext/language'
require 'repositext/r_file/content_at_specific'
require 'repositext/repository'
require 'repositext/text'
require 'repositext/utils/array_differ'
require 'repositext/utils/corresponding_primary_file_finder'
require 'repositext/utils/entity_encoder'
require 'repositext/utils/filename_part_extractor'
require 'repositext/utils/id_page_remover'
require 'repositext/utils/subtitle_filename_converter'
require 'repositext/utils/subtitle_mark_tools'
require 'repositext/validation'
require 'repositext/validation/utils/config'
require 'repositext/validation/utils/logger'
require 'repositext/validation/utils/logger_test'
require 'repositext/validation/utils/reportable'
require 'repositext/validation/utils/reporter'
require 'repositext/validation/utils/reporter_test'
require 'repositext/validation/validator'

# Dependency boundary

require 'kramdown/converter/latex_repositext_book'
require 'kramdown/converter/latex_repositext_comprehensive'
require 'kramdown/converter/latex_repositext_plain'
require 'kramdown/converter/latex_repositext_recording'
require 'kramdown/converter/latex_repositext_recording_merged'
require 'kramdown/converter/latex_repositext_translator'
require 'kramdown/converter/latex_repositext_web'
require 'kramdown/converter/subtitle_tagging'
require 'kramdown/mixins/ke_context_mixin'
require 'repositext/cli/long_descriptions_for_commands'
require 'repositext/cli/rtfile_parser'
require 'repositext/cli/utils'
require 'repositext/compare/record_id_and_paragraph_alignment'
require 'repositext/convert/latex_to_pdf'
require 'repositext/export/gap_mark_tagging'
require 'repositext/fix/adjust_gap_mark_positions'
require 'repositext/fix/adjust_merged_record_mark_positions'
require 'repositext/fix/convert_abbreviations_to_lower_case'
require 'repositext/fix/convert_folio_typographical_chars'
require 'repositext/fix/insert_record_mark_into_all_at_files'
require 'repositext/fix/move_subtitle_marks_to_nearby_sentence_boundaries'
require 'repositext/fix/normalize_editors_notes'
require 'repositext/fix/normalize_subtitle_mark_before_gap_mark_positions'
require 'repositext/fix/remove_underscores_inside_folio_paragraph_numbers'
require 'repositext/language/afrikaans'
require 'repositext/language/english'
require 'repositext/language/spanish'
require 'repositext/merge/accepted_corrections_into_content_at'
require 'repositext/merge/gap_mark_tagging_import_into_content_at'
require 'repositext/merge/record_marks_from_folio_xml_at_into_idml_at'
require 'repositext/merge/subtitle_marks_from_subtitle_import_into_content_at'
require 'repositext/merge/titles_from_folio_roundtrip_compare_into_content_at'
require 'repositext/process/fix/add_initial_persistent_subtitle_ids'
require 'repositext/process/split/subtitles'
require 'repositext/r_file'
require 'repositext/report/invalid_typographic_quotes'
require 'repositext/sync/subtitle_mark_character_positions'
require 'repositext/validation/content'
require 'repositext/validation/docx_post_import'
require 'repositext/validation/docx_pre_import'
require 'repositext/validation/folio_xml_post_import'
require 'repositext/validation/folio_xml_pre_import'
require 'repositext/validation/gap_mark_tagging_post_import'
require 'repositext/validation/gap_mark_tagging_pre_import'
require 'repositext/validation/html_post_import'
require 'repositext/validation/idml_import_consistency'
require 'repositext/validation/idml_post_import'
require 'repositext/validation/idml_pre_import'
require 'repositext/validation/paragraph_style_consistency'
require 'repositext/validation/rtfile'
require 'repositext/validation/subtitle_mark_no_significant_changes'
require 'repositext/validation/subtitle_post_import'
require 'repositext/validation/subtitle_pre_import'
require 'repositext/validation/test'
require 'repositext/validation/validator/eagles_connected_to_paragraph'
require 'repositext/validation/validator/folio_import_round_trip'
require 'repositext/validation/validator/gap_mark_counts_match'
require 'repositext/validation/validator/gap_mark_tagging_import_consistency'
require 'repositext/validation/validator/html_import_consistency'
require 'repositext/validation/validator/idml_import_consistency'
require 'repositext/validation/validator/idml_import_round_trip'
require 'repositext/validation/validator/idml_import_syntax'
require 'repositext/validation/validator/kramdown_syntax'
require 'repositext/validation/validator/kramdown_syntax_at'
require 'repositext/validation/validator/kramdown_syntax_pt'
require 'repositext/validation/validator/paragraph_style_consistency'
require 'repositext/validation/validator/subtitle_import_consistency'
require 'repositext/validation/validator/subtitle_mark_at_beginning_of_every_paragraph'
require 'repositext/validation/validator/subtitle_mark_counts_match'
require 'repositext/validation/validator/subtitle_mark_no_significant_changes'
require 'repositext/validation/validator/subtitle_mark_spacing'
require 'repositext/validation/validator/utf8_encoding'
# NOTE: Don't require the custom validator examples as they interfere with specs
# require 'repositext/validation/a_custom_example'
# require 'repositext/validation/validator/a_custom_example'

# Dependency boundary

require 'kramdown/parser/docx/ke_context'
require 'kramdown/parser/folio/ke_context'
require 'repositext/cli/commands/compare'
require 'repositext/cli/commands/convert'
require 'repositext/cli/commands/copy'
require 'repositext/cli/commands/fix'
require 'repositext/cli/commands/init'
require 'repositext/cli/commands/merge'
require 'repositext/cli/commands/move'
require 'repositext/cli/commands/report'
require 'repositext/cli/commands/split'
require 'repositext/cli/commands/sync'
require 'repositext/cli/commands/validate'
require 'repositext/cli/config'
require 'repositext/process/split/subtitles/bilingual_sequence_pair'
require 'repositext/process/split/subtitles/bilingual_sequence_pair/paragraphs_aligner'
require 'repositext/process/split/subtitles/bilingual_sequence_pair/paragraphs_aligner/with_different_paragraph_counts'
require 'repositext/process/split/subtitles/bilingual_sequence_pair/paragraphs_aligner/with_different_paragraph_counts/nw_aligner'
require 'repositext/process/split/subtitles/bilingual_sequence_pair/paragraphs_aligner/with_identical_paragraph_counts'
require 'repositext/process/split/subtitles/bilingual_paragraph_pair'
require 'repositext/process/split/subtitles/bilingual_text_pair'
require 'repositext/process/split/subtitles/paragraph'
require 'repositext/process/split/subtitles/sentence'
require 'repositext/process/split/subtitles/sequence'

# Dependency boundary

require 'repositext/cli/commands/export'
require 'repositext/cli/commands/import'

# Dependency boundary

require 'repositext/cli'
