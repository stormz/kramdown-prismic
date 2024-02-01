# frozen_string_literal: true

require 'kramdown/parser/base'

module KramdownPrismic
  module Parser
    Utils = Kramdown::Utils
    Element = Kramdown::Element
    
    # Converter for the Prismic API V2 format (aka Migration API format)
    class MigrationApi < Kramdown::Parser::Base
      def parse
        @root.options[:encoding] = 'UTF-8'
        @root.children = @source.reduce([]) do |memo, block|
          parse_element(block, memo)
        end
      end

      protected

      def parse_element(block, memo)
        type = block[:type].gsub('-', '_')
        type = 'heading' if type.match(/heading/)
        if type == 'list_item'
          parse_list(:ul, block, memo)
          memo
        elsif type == 'o_list_item'
          parse_list(:ol, block, memo)
          memo
        else
          element = send("parse_#{type}", block)
          parse_spans(element, block)
          memo << element
        end
      end

      def parse_heading(block)
        level = block[:type].match(/heading([1-6])/)[1].to_i
        Element.new(:header, nil, nil, { level: level, raw_text: '' })
      end

      def parse_paragraph(_block)
        Element.new(:p)
      end

      def parse_image(block)
        p = Element.new(:p)
        # Note that in V2 format the `data` attribute is inlined
        img = Element.new(:img, nil, { 'src' => block.dig(:origin, :url), 'alt' => block[:alt] })
        if block[:linkTo]
          a = Element.new(:a, nil, { 'href' => block.dig(:linkTo, :url) })
          a.children << img
          p.children << a
        else
          p.children << img
        end
        p
      end

      def parse_preformatted(_block)
        Element.new(:blockquote)
      end

      def parse_list(type, block, memo)
        list = memo.last
        unless list && list.type == type
          list = Element.new(type)
          memo << list
        end
        li = Element.new(:li, nil, nil)
        list.children << li
        p = Element.new(:p, nil, nil, transparent: true)
        li.children << p
        parse_spans(p, block)
      end

      def parse_embed(block)
        # Note how in V2 format `data` attribute is now `oembed`
        Element.new(:html_element, 'iframe', { src: block[:oembed][:embed_url] })
      end

      def parse_spans(element, block)
        stack = []

        # In V2 some entities (such as images or embeds) don't get content attributes
        return unless block.has_key?(:text)

        (block[:text].size + 1).times do |index|
          starting_spans = find_starting_spans_for(block, index)
          ending_spans   = find_ending_spans_for(block, index)

          ending_spans.each do |_ending_span|
            el = stack.pop
            if stack.empty?
              element.children << el
            else
              stack[-1].children << el
            end
          end
          starting_spans.each do |starting_span|
            stack << if starting_span[:type] == 'hyperlink'
                       Element.new(:a, nil, { 'href' => starting_span[:data][:url] })
                     else
                       Element.new(starting_span[:type].to_sym)
                     end
          end

          char = block[:text][index]
          next if char.nil?

          current_text = if stack.empty?
                           element.children.last
                         else
                           stack[-1].children.last
                         end
          if current_text.nil? || current_text.type != :text
            current_text = Element.new(:text, '')
            if stack.empty?
              element.children << current_text
            else
              stack[-1].children << current_text
            end
          end
          current_text.value += char
        end
      end

      def find_starting_spans_for(block, index)
        # Note how in V2 `content` attributes are inlined
        block[:spans].find_all do |span|
          span[:start] == index
        end.sort_by do |span|
          -span[:end]
        end
      end

      def find_ending_spans_for(block, index)
        # Note how in V2 `content` attributes are inlined
        block[:spans].find_all do |span|
          span[:end] == index
        end
      end
    end
  end
end
