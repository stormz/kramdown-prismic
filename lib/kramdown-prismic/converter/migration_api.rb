# frozen_string_literal: true

require_relative 'import_api'

module KramdownPrismic
  module Converter
    # Converter for the Prismic API V2 format (aka Migration API format)
    #
    # It's basically thing wrapper over the V1 converter, that applies
    # common conversion rules between those formats when emitting an element
    class MigrationApi < ImportApi
      def convert_element(element)
        result = super

        return nil unless result

        case result
          when Array then result.map(&FormatUtil::V2.method(:from_v1))
          else FormatUtil::V2.from_v1(result)
        end
      end
    end
  end
end
