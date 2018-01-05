require 'minitest/autorun'
require 'kramdown-prismic'

class KramdownPrismicParserTest < Minitest::Test
  def test_parse_heading
    prismic = [
      {
        type: "heading1",
        content: {
          text: "This is the document title",
          spans: []
        }
      }
    ]
    expected = "# This is the document title\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_heading2
    prismic = [
      {
        type: "heading2",
        content: {
          text: "This is an h2 title",
          spans: []
        }
      }
    ]
    expected = "## This is an h2 title\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph
    prismic = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: []
        }
      }
    ]
    expected = "This is a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_spans
    prismic = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "em",
              start: 0,
              end: 4
            }
          ]
        }
      }
    ]
    expected = "*This* is a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_multiple_spans
    prismic = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "em",
              start: 0,
              end: 4
            },
            {
              type: "strong",
              start: 5,
              end: 7
            }
          ]
        }
      }
    ]
    expected = "*This* **is** a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_link
    prismic = [
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
    expected = "[This is a paragraph][1]\n\n\n\n[1]: https://prismic.io\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_nested_spans
    prismic = [
      {
        type: "paragraph",
        content: {
          text: "This is a paragraph",
          spans: [
            {
              type: "em",
              start: 0,
              end: 4
            },
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
    expected = "[*This* is a paragraph][1]\n\n\n\n[1]: https://prismic.io\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_image
    prismic = [
      {
        type: "image",
        content: {
          text: "",
          spans: []
        },
        data: {
          origin: {
            url: '/img.png'
          },
          alt: 'alt text'
        }
      }
    ]
    expected = "![alt text](/img.png)\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_preformatted
    prismic = [
      {
        type: "preformatted",
        content: {
          text: "This is a pre block\n",
          spans: []
        }
      }
    ]
    expected = "> This is a pre block \n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic)
    assert_equal expected, doc.to_kramdown
  end
end
