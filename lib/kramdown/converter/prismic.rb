require 'kramdown/converter/base'

module Kramdown
  module Converter
    class Prismic < Base
      def convert(root)
        cleanup_ast(root).map { |child|
          convert_element(child)
        }.compact.flatten
      end

      private

      def cleanup_ast(root)
        remove_blanks(root)
        root.children.map do |child|
          elements = []
          extract_non_nestable_elements(child, elements)
          [child, elements]
        end.flatten.compact
      end

      def remove_blanks(root)
        root.children = root.children.inject([]) do |memo, child|
          unless child.type == :blank
            remove_blanks(child)
            memo << child
          end
          memo
        end
      end

      def extract_non_nestable_elements(child, elements)
        child.children = child.children.inject([]) do |memo, element|
          if element.type == :img
            elements << element
          elsif element.type == :ul
            warning('nested list moved to the top level')
            elements << element
            extract_non_nestable_elements(element, elements)
          else
            memo << element
            extract_non_nestable_elements(element, elements)
          end
          memo
        end
      end

      def convert_element(element)
        send("convert_#{element.type}", element)
      end

      def convert_header(element)
        {
          type: "heading#{element.options[:level]}",
          content: extract_content(element)
        }
      end

      def convert_p(element)
        {
          type: "paragraph",
          content: extract_content(element)
        }
      end

      def convert_ol(element)
        convert_list(element, 'o-list-item')
      end

      def convert_ul(element)
        convert_list(element, 'list-item')
      end

      def convert_list(element, type)
        element.children.map do |child|
          convert_li(type, child)
        end
      end

      def convert_li(type, element)
        {
          type: type,
          content: extract_content(element)
        }
      end

      def convert_codeblock(element)
        {
          type: 'preformatted',
          content: {
            text: element.value,
            spans: []
          }
        }
      end

      def convert_blockquote(element)
        {
          type: 'preformatted',
          content: extract_content(element)
        }
      end

      def convert_hr(element)
      end

      def convert_img(element)
        {
          type: 'image',
          content: {
            text: '',
            spans: []
          },
          data: {
            url: element.attr["src"],
            alt: element.attr["alt"]
          }
        }
      end

      def convert_html_element(element)
        warning('translating html elements is not supported')
        nil
      end

      def convert_table(element)
        warning('translating table is not supported')
        nil
      end

      def convert_dl(element)
        warning('translating dl is not supported')
        nil
      end

      def convert_math(element)
        warning('translating math is not supported')
        nil
      end

      def convert_comment(element)
        warning('translating comment is not supported')
        nil
      end

      def convert_xml_comment(element)
        warning('translating xml_comment is not supported')
        nil
      end

      def convert_xml_pi(element)
        warning('translating xml_pi is not supported')
        nil
      end

      def convert_raw(element)
        warning('translating raw is not supported')
        nil
      end

      def extract_content(element, memo={text: '', spans: []})
        element.children.inject(memo) do |memo2, child|
          send("extract_span_#{child.type}", child, memo2)
          memo2
        end
      end

      def insert_span(element, memo, span)
        span[:start] = memo[:text].size
        extract_content(element, memo)
        span[:end] = memo[:text].size
        memo[:spans] << span
        memo
      end

      def extract_span_text(element, memo)
        memo[:text] += element.value
        memo
      end

      def extract_span_a(element, memo)
        insert_span(element, memo, {
                      type: 'hyperlink',
                      data: {
                        url: element.attr["href"]
                      }
                    })
      end

      def extract_span_strong(element, memo)
        insert_span(element, memo, {
                      type: 'strong'
                    })
      end

      def extract_span_em(element, memo)
        insert_span(element, memo, {
                      type: 'em'
                    })
      end

      def extract_span_p(element, memo)
        extract_content(element, memo)
      end

      def extract_span_br(element, memo)
        memo[:text] += "\n"
      end

      def extract_span_html_element(element, memo)
        warning('translating html elements is not supported')
      end

      def extract_span_footnote(element, memo)
        warning('translating footnote is not supported')
      end

      def extract_span_abbreviation(element, memo)
        warning('translating abbreviation is not supported')
        memo[:text] += element.value
      end

      TYPOGRAPHIC_SYMS = {
        mdash: [::Kramdown::Utils::Entities.entity('mdash')],
        ndash: [::Kramdown::Utils::Entities.entity('ndash')],
        hellip: [::Kramdown::Utils::Entities.entity('hellip')],
        laquo_space: [::Kramdown::Utils::Entities.entity('laquo'), ::Kramdown::Utils::Entities.entity('nbsp')],
        raquo_space: [::Kramdown::Utils::Entities.entity('nbsp'), ::Kramdown::Utils::Entities.entity('raquo')],
        laquo: [::Kramdown::Utils::Entities.entity('laquo')],
        raquo: [::Kramdown::Utils::Entities.entity('raquo')]
      }
      def extract_span_typographic_sym(element, memo)
        value = TYPOGRAPHIC_SYMS[element.value].map {|e| e.char }.join('')
        memo[:text] += value
      end

      def extract_span_entity(element, memo)
        memo[:text] += element.value.char
      end

      def extract_span_smart_quote(element, memo)
        memo[:text] += ::Kramdown::Utils::Entities.entity(element.value.to_s).char
      end
    end
  end
end
