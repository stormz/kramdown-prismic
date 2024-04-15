# frozen_string_literal: true

module KramdownPrismic
  module FormatUtil
    # Utilities for converting to API V2 representation (used e.g. in the Migration API)
    module V2
      class << self
        # Convert element from API V1 representation
        def from_v1(element)
          element = element.dup
          type = element[:type]
          
          # All content attributes are inlined into the enclosing object
          content = element.delete(:content)&.dup || {}

          # Except some types don't have content-related attributes at all
          element = element.merge(content) unless type == "image" || type == "embed"

          # If there's some special processing needed for the element type, do that
          element = process_element(element)

          # Adjust any span-level elements to the new format
          element[:spans] = element[:spans].map(&method(:process_span_element)) if element.has_key?(:spans)

          element
        end

        private

        def process_element(element)
          processor_method = :"#{ element[:type] }_from_v1"

          # We need to include private methods here
          return element unless respond_to?(processor_method, true)
          
          send(processor_method, element)
        end

        def process_span_element(element)
          processor_method = :"span_#{ element[:type] }_from_v1"

          # We need to include private methods here
          return element unless respond_to?(processor_method, true)
          
          send(processor_method, element)
        end

        def image_from_v1(element)
          # Attributes describing the image are no longer nested under `data`
          data = element.delete(:data)&.dup

          # The `id` and `url`` attributes need to be inlined into the top-level object
          origin = data.delete(:origin)

          data[:id] = origin[:id] if origin[:id]
          data[:url] = origin[:url] if origin[:url]

          # Image dimesions need to nested into an object under `dimensions` ke
          height = data.delete(:height)
          width = data.delete(:width)

          if !(dimensions = {:height => height, :width => width}.compact).empty?
            data[:dimensions] = dimensions
          end

          # Cropping attributes need to inlined into the parent `edit` object
          if data.dig(:edit, :crop)
            data[:edit] = data[:edit].dup

            data[:edit].merge!(data[:edit].delete(:crop))
          end

          # The image attributes are instead inlined into the top-level object
          element.merge(data)
        end

        def embed_from_v1(element)
          data = element.delete(:data)

          # The object with embed attributes is renamed
          element[:oembed] = data
  
          element
        end

        def span_hyperlink_from_v1(element)
          data = element[:data].dup
          uri = data.delete(:url)

          # Prismic treats links to internal assets specially
          case link_kind(uri)
            when :web      then data.merge!(url: uri, link_type: "Web")
            when :document then data.merge!(wioUrl: uri, link_type: "Document")
            when :media    then data.merge!(wioUrl: uri, link_type: "Media")
          end

          element[:data] = data
          element
        end

        def link_kind(uri)
          case uri 
            when /^wio:\/\/documents\// then :document
            when /^wio:\/\/medias\// then :media
            else :web
          end
        end
      end
    end
  end
end