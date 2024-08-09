# frozen_string_literal: true

require 'minitest/autorun'
require 'kramdown-prismic'

class KramdownPrismicMigrationApiParserTest < Minitest::Test
  6.times do |heading|
    define_method "test_parse_heading_#{heading}" do
      prismic = [
        {
          type: "heading#{heading + 1}",
          text: 'This is the document title',
          spans: []
        }
      ]
      expected = "#{'#' * (heading + 1)} This is the document title\n\n"
      doc = Kramdown::Document.new(prismic, input: :prismic_v2)
      assert_equal expected, doc.to_kramdown
    end
  end

  def test_parse_paragraph
    prismic = [
      {
        type: 'paragraph',
        text: 'This is a paragraph',
        spans: []
      }
    ]
    expected = "This is a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_spans
    prismic = [
      {
        type: 'paragraph',
        text: 'This is a paragraph',
        spans: [
          {
            type: 'em',
            start: 0,
            end: 4
          }
        ]
      }
    ]
    expected = "*This* is a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_multiple_spans
    prismic = [
      {
        type: 'paragraph',
        text: 'This is a paragraph',
        spans: [
          {
            type: 'em',
            start: 0,
            end: 4
          },
          {
            type: 'strong',
            start: 5,
            end: 7
          }
        ]
      }
    ]
    expected = "*This* **is** a paragraph\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_link
    prismic = [
      {
        type: 'paragraph',
        text: 'This is a paragraph',
        spans: [
          {
            type: 'hyperlink',
            start: 0,
            end: 19,
            data: {
              url: 'https://prismic.io',
              link_type: 'Web'
            }
          }
        ]
      }
    ]
    expected = "[This is a paragraph][1]\n\n\n\n[1]: https://prismic.io\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_paragraph_with_nested_spans
    prismic = [
      {
        type: 'paragraph',
        text: 'This is a paragraph',
        spans: [
          {
            type: 'em',
            start: 0,
            end: 4
          },
          {
            type: 'hyperlink',
            start: 0,
            end: 19,
            data: {
              url: 'https://prismic.io'
            }
          }
        ]
      }
    ]
    expected = "[*This* is a paragraph][1]\n\n\n\n[1]: https://prismic.io\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_list_item
    prismic = [
      {
        type: 'list-item',
        text: 'Hello',
        spans: []
      },
      {
        type: 'list-item',
        text: 'World',
        spans: []
      }
    ]
    expected = "* Hello\n* World\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_list_item_and_spans
    prismic = [
      {
        type: 'list-item',
        text: 'Hello',
        spans: [
          {
            type: 'em',
            start: 0,
            end: 5
          }
        ]
      },
      {
        type: 'list-item',
        text: 'World',
        spans: []
      }
    ]
    expected = "* *Hello*\n* World\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_o_list_item
    prismic = [
      {
        type: 'o-list-item',
        text: 'Hello',
        spans: []
      },
      {
        type: 'o-list-item',
        text: 'World',
        spans: []
      }
    ]
    expected = "1.  Hello\n2.  World\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_o_list_item_and_list_item
    prismic = [
      {
        type: 'o-list-item',
        text: 'Hello',
        spans: []
      },
      {
        type: 'o-list-item',
        text: 'World',
        spans: []
      },
      {
        type: 'list-item',
        text: 'Test',
        spans: []
      },
      {
        type: 'list-item',
        text: 'roger',
        spans: []
      }
    ]
    expected = "1.  Hello\n2.  World\n\n* Test\n* roger\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_image
    prismic = [
      {
        type: 'image',
        url: '/img.png',
        alt: 'alt text'
      }
    ]
    expected = "![alt text](/img.png)\n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  # TODO: should probably be unsupported
  def test_parse_img_with_link
    prismic = [
      {
        type: 'image',
        url: '/img.png',
        alt: 'alt text',
        linkTo: {
          url: 'https://example.net/'
        }
      }
    ]
    expected = "[![alt text](/img.png)][1]\n\n\n\n[1]: https://example.net/\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_preformatted
    prismic = [
      {
        type: 'preformatted',
        text: "This is a pre block\n",
        spans: []
      }
    ]
    expected = "> This is a pre block \n\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end

  def test_parse_embed
    prismic = [
      {
        type: 'embed',
        oembed: {
          type: 'video',
          embed_url: 'https://www.youtube.com/watch?v=y6y_4_b6RS8'
        },
      }
    ]
    expected = "<iframe src=\"https://www.youtube.com/watch?v=y6y_4_b6RS8\"></iframe>\n"
    doc = Kramdown::Document.new(prismic, input: :prismic_v2)
    assert_equal expected, doc.to_kramdown
  end
end
