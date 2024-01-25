# frozen_string_literal: true

require 'kramdown'

require 'kramdown-prismic/parser/prismic'
require 'kramdown-prismic/converter/prismic'
require 'kramdown-prismic/version'

module Kramdown
  module Converter
    Prismic = KramdownPrismic::Converter::Prismic
  end

  module Parser
    Prismic = KramdownPrismic::Parser::Prismic
  end
end