# frozen_string_literal: true

require_relative 'migration_api'

module KramdownPrismic
  module Parser
    # Converter for the Prismic API V1 format (aka Import API format)
    #
    # It's basically thing wrapper over the V2 converter, that applies
    # common conversion rules between those formats before parsing
    # an element
    class ImportApi < MigrationApi
      protected

      def parse_element(block, memo)
        converted = FormatUtil::V2.from_v1(block)

        super(converted, memo)
      end
    end
  end
end
