# frozen_string_literal: true

module Kramdown
  module Parser
    class Prismic < Base
      def parse
        @root.options[:encoding] = 'UTF-8'
        @root.children = @source.map do |block|
          type = block[:type]
          type = 'heading' if type.match(/heading/)
          element = send("parse_#{type}", block)
          parse_spans(element, block)
          element
        end
      end

      private

      def parse_heading(block)
        level = block[:type].match(/heading([1-6])/)[1].to_i
        Kramdown::Element.new(:header, nil, nil, { level: level, raw_text: '' })
      end

      def parse_paragraph(_block)
        Kramdown::Element.new(:p)
      end

      def parse_image(block)
        p = Kramdown::Element.new(:p)
        img = Kramdown::Element.new(:img, nil, { 'src' => block[:data][:origin][:url], 'alt' => block[:data][:alt] })
        p.children << img
        p
      end

      def parse_preformatted(_block)
        Kramdown::Element.new(:blockquote)
      end

      def parse_embed(block)
        Kramdown::Element.new(:html_element, 'iframe', { src: block[:data][:embed_url] })
      end

      def parse_spans(element, block)
        stack = []

        (block[:content][:text].size + 1).times do |index|
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

          char = block[:content][:text][index]
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
        block[:content][:spans].find_all do |span|
          span[:start] == index
        end.sort_by do |span|
          -span[:end]
        end
      end

      def find_ending_spans_for(block, index)
        block[:content][:spans].find_all do |span|
          span[:end] == index
        end
      end
    end
  end
end
