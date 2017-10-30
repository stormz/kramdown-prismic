require 'minitest/autorun'
require 'kramdown-prismic'

class KramdownPrismicTest < Minitest::Test
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

  def test_convert_heading_with_spans
    expected = [
      {
        type: "heading2",
        content: {
          text: "This is a document title",
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
    markdown = "## *This* is a document title"
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

  def test_convert_paragraph_with_em
    expected = [
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
    markdown = "*This* is a paragraph"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_list_o
    expected = [
      {
        type: "o-list-item",
        content: {
          text: "This is a list item",
          spans: [
            {
              type: "em",
              start: 0,
              end: 4
            }
          ]
        }
      },
      {
        type: "o-list-item",
        content: {
          text: "This is a second list item",
          spans: []
        }
      }
    ]
    markdown = "1. *This* is a list item\n2. This is a second list item"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_list_u
    expected = [
      {
        type: "list-item",
        content: {
          text: "This is a list item",
          spans: [
            {
              type: "em",
              start: 0,
              end: 4
            }
          ]
        }
      },
      {
        type: "list-item",
        content: {
          text: "This is a second list item",
          spans: []
        }
      }
    ]
    markdown = "- *This* is a list item\n- This is a second list item"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_nested_ul
    expected = [
      {
        type: "list-item",
        content: {
          text: "item1\n",
          spans: []
        }
      },
      {
        type: "list-item",
        content: {
          text: "item2",
          spans: []
        }
      }
    ]
    markdown = "- item1\n  - item2"
    doc = Kramdown::Document.new(markdown, input: :markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_nested_nested_ul
    expected = [
      {
        type: "list-item",
        content: {
          text: "item1\n",
          spans: []
        }
      },
      {
        type: "list-item",
        content: {
          text: "item2\n",
          spans: []
        }
      },
      {
        type: "list-item",
        content: {
          text: "item3",
          spans: []
        }
      }
    ]
    markdown = "- item1\n  - item2\n    - item3"
    doc = Kramdown::Document.new(markdown, input: :markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 2, doc.warnings.size
  end

  def test_convert_preformatted
    expected = [
      {
        type: "preformatted",
        content: {
          text: "This is a pre block\n",
          spans: []
        }
      }
    ]
    markdown = "    This is a pre block\n"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_blockquote
    expected = [
      {
        type: "preformatted",
        content: {
          text: "This is a blockquote",
          spans: []
        }
      }
    ]
    markdown = "> This is a blockquote\n"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_empty
    expected = []
    markdown = ""
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_span_blank
    expected = [
      {type: "o-list-item",
       content: {
         text: "Testtest",
         spans: []
       }
      }
    ]
    markdown = "\n1. Test\n\n    test\n"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_hr
    expected = []
    markdown = "---"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_img
    expected = [
      {
        type: "paragraph",
        content: {
          text: "",
          spans: []
        }
      },
      {
        type: "image",
        content: {
          text: "",
          spans: []
        },
        data: {
          url: '/img.png',
          alt: 'alt text'
        }
      }
    ]
    markdown =  "![alt text](/img.png)"
    assert_equal expected, Kramdown::Document.new(markdown).to_prismic
  end

  def test_convert_double_img
    expected = [
      {
        type: "paragraph",
        content: {
          text: "",
          spans: []
        }
      },
      {
        type: "image",
        content: {
          text: "",
          spans: []
        },
        data: {
          url: '/img.png',
          alt: ''
        }
      },
      {
        type: "image",
        content: {
          text: "",
          spans: []
        },
        data: {
          url: '/img2.png',
          alt: ''
        }
      }
    ]
    markdown =  "![](/img.png)![](/img2.png)"
    assert_equal expected, Kramdown::Document.new(markdown).to_prismic
  end

  def test_convert_entity
    expected = [
      {type: "paragraph",
       content: {
         text: "\u00a0",
         spans: []
       }
      }
    ]
    markdown = "&nbsp;"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  def test_convert_br
    expected = [
      {type: "paragraph",
       content: {
         text: "Test\n",
         spans: []
       }
      }
    ]
    html = "<p>Test<br></p>"
    assert_equal expected, Kramdown::Document.new(html, input: :html).to_prismic
  end

  def test_convert_html
    expected = []
    html = "<div></div>"
    doc = Kramdown::Document.new(html, input: :markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_span_html
    expected = [
      {type: "paragraph",
       content: {
         text: "",
         spans: []
       }
      }
    ]
    html = "<br>"
    doc = Kramdown::Document.new(html, input: :markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end
end
