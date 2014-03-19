# NOTE: None of the CLI code is required here. It's required in lib/rt/cli.rb

require 'awesome_print'
require 'erb'
require 'json'
require 'kramdown/document'
require 'suspension'

require 'patch_string'

require 'kramdown/converter/graphviz'
require 'kramdown/converter/html_doc'
require 'kramdown/converter/icml'
require 'kramdown/converter/idml_story'
require 'kramdown/converter/kramdown_repositext'
require 'kramdown/converter/patch_base'
require 'kramdown/converter/plain_text'
require 'kramdown/element_rt'
require 'kramdown/mixins/adjacent_element_merger'
require 'kramdown/mixins/nested_ems_processor'
require 'kramdown/mixins/tmp_em_class_processor'
require 'kramdown/mixins/tree_cleaner'
require 'kramdown/mixins/whitespace_out_pusher'
require 'kramdown/parser/folio'
require 'kramdown/parser/folio/ke_context'
require 'kramdown/parser/idml'
require 'kramdown/parser/idml_story'
require 'kramdown/parser/kramdown_repositext'
require 'kramdown/patch_element'

require 'repositext/fix/adjust_merged_record_mark_positions'
require 'repositext/fix/convert_abbreviations_to_lower_case'
require 'repositext/fix/convert_folio_typographical_chars'
