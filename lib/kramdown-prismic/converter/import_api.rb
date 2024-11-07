# frozen_string_literal: true

require 'kramdown/converter/base'

module KramdownPrismic
  module Converter
    Utils = Kramdown::Utils
    Element = Kramdown::Element
    
    # Converter for the Prismic API V1 format (aka Import API format)
    class ImportApi < Kramdown::Converter::Base
      def convert(root)
        cleanup_ast(root).map do |child|
          convert_element(child)
        end.compact.flatten
      end

      protected

      def cleanup_ast(root)
        remove_blanks(root)
        root.children.map do |child|
          elements = []
          extract_non_nestable_elements(child, elements)
          [child, elements]
        end.flatten.compact
      end

      def remove_blanks(root)
        root.children = root.children.each_with_object([]) do |child, memo|
          unless child.type == :blank
            remove_blanks(child)
            memo << child
          end
        end
      end

      def extract_non_nestable_elements(child, elements)
        child.children = child.children.each_with_object([]) do |element, memo|
          if element.type == :a && element.children.size == 1 && element.children.first.type == :img
            elements << element
          elsif element.type == :img
            elements << element
            if child.children.size > 1
              warning('images inside content will be moved to the top level and may be rendered differently')
            end
          elsif [:ul, :ol].include?(element.type)
            warning('nested list moved to the top level')
            elements << element
            extract_non_nestable_elements(element, elements)
          elsif element.type == :header
            warning('header moved to the top level')
            elements << element
            extract_non_nestable_elements(element, elements)
          else
            memo << element
            extract_non_nestable_elements(element, elements)
          end
        end
      end

      def convert_element(element)
        result = send("convert_#{element.type}", element)

        case result
          when nil then nil
          when Array
            result.map(&method(:with_sorted_spans))
          else
            with_sorted_spans(result)
        end
      end

      # Sort spans to match default Prismic ordering - it is not
      # an API requirement, but makes testing easier if you have
      # a matching ordering
      def with_sorted_spans(element)
        if (spans = element.dig(:content, :spans))
          element[:content][:spans] = spans.sort do |lhs, rhs|
            [lhs[:type], lhs[:start]] <=> [rhs[:type], rhs[:start]]
          end
        end

        element
      end

      def convert_header(element)
        {
          type: "heading#{element.options[:level]}",
          content: extract_content(element)
        }
      end

      def convert_p(element)
        return nil if element.children.size.zero?

        {
          type: 'paragraph',
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

      def convert_hr(element); end
      def convert_br(element); end

      def convert_img(element)
        {
          type: 'image',
          content: {
            text: '',
            spans: []
          },
          data: {
            origin: {
              url: element.attr['src']
            },
            alt: element.attr['alt']
          }
        }
      end

      # This can only apply when an link with an image inside has been detected
      # TODO: This is not quite true, it's also callded with (at least) a top-level `<a>` as well
      def convert_a(element)
        image = element.children.first
        {
          type: 'image',
          content: {
            text: '',
            spans: []
          },
          data: {
            origin: {
              url: image.attr['src']
            },
            alt: image.attr['alt'],
            linkTo: {
              url: element.attr['href']
            }
          }
        }
      end

      def convert_strong(element)
        convert_sub_html_element(element, 'strong')
      end

      def convert_em(element)
        convert_sub_html_element(element, 'em')
      end

      def convert_sub_html_element(element, type)
        content = extract_content(element)
        content[:spans].push({ type: type, start: 0, end: content[:text].size })
        {
          type: 'paragraph',
          content: content
        }
      end

      def convert_html_element(element)
        if element.value == 'iframe'
          {
            type: 'embed',
            content: {
              text: '',
              spans: []
            },
            data: {
              embed_url: element.attr['src'],
              type: 'link'
            }
          }
        else
          warning('translating html elements is not supported')
          nil
        end
      end

      def convert_table(_element)
        warning('translating table is not supported')
        nil
      end

      def convert_dl(_element)
        warning('translating dl is not supported')
        nil
      end

      def convert_math(_element)
        warning('translating math is not supported')
        nil
      end

      def convert_comment(_element)
        warning('translating comment is not supported')
        nil
      end

      def convert_xml_comment(_element)
        warning('translating xml comment is not supported')
        nil
      end

      def convert_raw(_element)
        warning('translating raw is not supported')
        nil
      end

      def convert_text(element)
        {
          type: 'paragraph',
          content: {
            text: element.value,
            spans: []
          }
        }
      end

      def extract_content(element, memo = { text: '', spans: [] })
        element.children.each_with_object(memo) do |child, memo2|
          send("extract_span_#{child.type}", child, memo2)
        end
      end

      def insert_span(element, memo, span_attributes)
        # Attributes are inserted in order of:
        #   type, start, end, other attributes
        # again, for slighly simpler comparisions
        # against typical Prismic ordering in tests
        span = {
          type: span_attributes.delete(:type),
        }

        span[:start] = memo[:text].size
        extract_content(element, memo)
        span[:end] = memo[:text].size

        span.merge!(span_attributes)

        memo[:spans] << span
        memo
      end

      def extract_span_text(element, memo)
        memo[:text] += element.value
        memo
      end

      def extract_span_a(element, memo)
        target = element.attr['target']
        insert_span(element, memo, {
                      type: 'hyperlink',
                      data: {
                        url: element.attr['href'],
                        **(target ? { target: target } : {}),
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

      def extract_span_br(_element, memo)
        memo[:text] += "\n"
      end

      def extract_span_codespan(element, memo)
        warning('translating inline code is not supported')
        memo[:text] += element.value
      end

      def extract_span_html_element(element, memo)
        if respond_to?("extract_span_#{element.value}", true)
          send("extract_span_#{element.value}", element, memo)
        else
          warning("translating html element '#{element.value}' is not supported")
        end
      end

      def extract_span_footnote(_element, _memo)
        warning('translating footnote is not supported')
      end

      def extract_span_abbreviation(element, memo)
        warning('translating abbreviation is not supported')
        memo[:text] += element.value
      end

      def extract_span_xml_comment(element, memo)
        warning('translating xml comment is not supported')
      end

      TYPOGRAPHIC_SYMS = {
        mdash: [Utils::Entities.entity('mdash')],
        ndash: [Utils::Entities.entity('ndash')],
        hellip: [Utils::Entities.entity('hellip')],
        laquo_space: [Utils::Entities.entity('laquo'), Utils::Entities.entity('nbsp')],
        raquo_space: [Utils::Entities.entity('nbsp'), Utils::Entities.entity('raquo')],
        laquo: [Utils::Entities.entity('laquo')],
        raquo: [Utils::Entities.entity('raquo')]
      }.freeze
      def extract_span_typographic_sym(element, memo)
        value = TYPOGRAPHIC_SYMS[element.value].map(&:char).join('')
        memo[:text] += value
      end

      def extract_span_entity(element, memo)
        memo[:text] += element.value.char
      end

      def extract_span_smart_quote(element, memo)
        memo[:text] += Utils::Entities.entity(element.value.to_s).char
      end
    end
  end
end
