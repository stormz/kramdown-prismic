require 'minitest/autorun'
require_relative './kramdown-prismic'

class KramdownPrismic < Minitest::Test
  def test_convert_heading
    expected = [
      {
        type: "heading1",
        content: {
          text: "This is the document title",
          spans: []
        }
      }
    ]
    markdown = "# This is the document title"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_heading2
    expected = [
      {
        type: "heading2",
        content: {
          text: "This is a document title",
          spans: []
        }
      }
    ]
    markdown = "## This is a document title"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_paragraph
    expected = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: []
        }
      }
    ]
    markdown = "This is a paragraph"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_paragraph_with_spans
    expected = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "hyperlink",
              start: 0,
              end: 19,
              data: {
                url: "https://prismic.io"
              }
            }
          ]
        }
      }
    ]
    markdown = "[This is a paragraph](https://prismic.io)"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end
  
  def test_convert_paragraph_with_strong
    expected = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "strong",
              start: 0,
              end: 19
            }
          ]
        }
      }
    ]
    markdown = "**This is a paragraph**"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_paragraph_with_strong2
    expected = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "strong",
              start: 0,
              end: 4
            }
          ]
        }
      }
    ]
    markdown = "**This** is a paragraph"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end
end
