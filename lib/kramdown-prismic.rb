# frozen_string_literal: true

require 'kramdown'

require 'kramdown-prismic/version'
require 'kramdown-prismic/format_util'
require 'kramdown-prismic/parser/import_api'
require 'kramdown-prismic/parser/migration_api'
require 'kramdown-prismic/converter/import_api'
require 'kramdown-prismic/converter/migration_api'

# Injects Prismic converters and parsers so that Kramdown can see them
#
# At a high level we implement only one format for each and convert the
# other into it. Since conversion from the V1 to the V1 API format is
# simpler - we only need to inline a few files into their enclosing
# elements (see `FormatUtil::V2` for details) instead of tracking which
# of the fields should be nested from a flatter represenation - in each
# case we choose the format we can apply the V1 -> V2 conversion.
# 
# This means that:
#   * for the converter it's more conventient to implement it on the V1
#     format and then use `FormatUtil::V2.from_v1` to flatten it
#     appropriately _after_ the conversion, if output is in V2,
#   * for the parser it's more convenient to implement it on the V2
#     format and then use `FormatUtil::V2.from_v1` to flatten it
#     appropriately before parsing, if input is in V1.
module Kramdown
  module Converter
    Prismic = KramdownPrismic::Converter::ImportApi
    PrismicV2 = KramdownPrismic::Converter::MigrationApi
  end

  module Parser
    # NOTE: odd constant naming is due to how `input` parameter -> classname conversion is handled for
    #       parser, which - contrary to converters - doesn't handle PascalCase correctly:
    #       https://github.com/gettalong/kramdown/blob/REL_2_4_0/lib/kramdown/document.rb#L98-L102
    Prismic_v2 = KramdownPrismic::Parser::MigrationApi
    Prismic = KramdownPrismic::Parser::ImportApi
  end
end