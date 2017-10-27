require 'kramdown'

require 'kramdown/converter/base'

module Kramdown
  module Converter
    class Prismic < Base
      def convert(root)
        root.children.map { |child|
          convert_element(child)
        }.compact
      end

      def apply_template_after?
        false
      end

      def convert_element(element)
        send("convert_#{element.type}", element)
      end

      private

      def convert_header(element)
        {
          type: "heading#{element.options[:level]}",
          content: {
            text: element.options[:raw_text],
            spans: []
          }
        }
      end

      def convert_p(element)
        {
          type: "paragraph",
          content: extract_content(element)
        }
      end

      def extract_content(element, memo={text: '', spans: []})
        element.children.inject(memo) do |memo, child|
          send("extract_span_#{child.type}", child, memo)
          memo
        end
      end

      def extract_span_text(element, memo)
        memo[:text] += element.value
        memo
      end

      def extract_span_a(element, memo)
        start = memo[:text].size
        memo = extract_content(element, memo)
        memo[:spans] << {
          type: 'hyperlink',
          start: start,
          end: memo[:text].size,
          data: {
            url: element.attr["href"]
          }
        }
      end

      def extract_span_strong(element, memo)
        start = memo[:text].size
        memo = extract_content(element, memo)
        memo[:spans] << {
          type: 'strong',
          start: start,
          end: memo[:text].size
        }
      end
    end
  end
end
