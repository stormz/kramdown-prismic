# coding: utf-8
require 'minitest/autorun'
require 'kramdown-prismic'

class KramdownPrismicConverterTest < Minitest::Test
  6.times do |heading|
    define_method "test_convert_heading_#{heading}" do
      expected = [
        {
          type: "heading#{heading + 1}",
          content: {
            text: "This is the document title",
            spans: []
          }
        }
      ]
      markdown = "#{"#" * (heading + 1)} This is the document title"
      assert_equal expected, Kramdown::Document.new(markdown, input: :kramdown).to_prismic
    end
  end

  def test_convert_heading7
    expected = [
      {
        type: "heading6",
        content: {
          text: "# This is the document title",
          spans: []
        }
      }
    ]
    markdown = "####### This is the document title"
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
    markdown =  "![alt text](/img.png)"
    doc = Kramdown::Document.new(markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 0, doc.warnings.size
  end

  def test_convert_double_img
    expected = [
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
          origin: {
            url: '/img2.png'
          },
          alt: ''
        }
      }
    ]
    markdown =  "![](/img.png)![](/img2.png)"
    doc = Kramdown::Document.new(markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 2, doc.warnings.size
  end

  def test_convert_img_with_link
    expected = [
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
          alt: 'alt text',
          linkTo: {
            url: "https://example.net/"
          }
        }
      }
    ]
    markdown =  "[![alt text](/img.png)](https://example.net/)"
    doc = Kramdown::Document.new(markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 0, doc.warnings.size
  end

  def test_convert_entity
    expected = [
      {
        type: "paragraph",
        content: {
          text: "\u00a0",
          spans: []
        }
      }
    ]
    markdown = "&nbsp;"
    assert_equal expected, Kramdown::Document.new(markdown, input: :markdown).to_prismic
  end

  [['mdash' , ' ---', ' —'],
   ['ndash' , ' --', ' –'],
   ['hellip' , ' ...', ' …'],
   ['laquo' , ' <<', ' «'],
   ['raquo' , '>>', '»'],
   ['laquo_space' , ' << T', ' « T'],
   ['raquo_space' , ' >>', ' »']
  ].each do |symbol|
    define_method "test_convert_typographic_symbols_#{symbol[0]}" do
      expected = [
        {
          type: "paragraph",
          content: {
            text: "Hello#{symbol[2]}",
            spans: []
          }
        }
      ]
      markdown = "Hello#{symbol[1]}"
      assert_equal expected, Kramdown::Document.new(markdown, input: :kramdown).to_prismic
    end
  end

  def test_convert_smart_quote
    expected = [
      {type: "paragraph",
       content: {
         text: "Test\u2019",
         spans: []
       }
      }
    ]
    markdown = "Test'"
    assert_equal expected, Kramdown::Document.new(markdown, input: :kramdown).to_prismic
  end

  def test_convert_inline_code
    expected = [
      {
        type: "paragraph",
        content: {
          text: "Hello code",
          spans: []
        }
      }
    ]
    markdown = "Hello `code`"
    doc = Kramdown::Document.new(markdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
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
      {
        type: "paragraph",
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

  def test_convert_table
    expected = []
    markdown = "| First cell|Second cell|Third cell|"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_definition
    expected = []
    markdown = "kramdown\n: A Markdown-superset converter"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_math
    expected = []
    markdown = "$$ 5 + 5 $$"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_footnote
    expected = [
      {
        type: "paragraph",
        content: {
          text: "test",
          spans: []
        }
      }]
    markdown = "test[^1]\n\n[^1]: test"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_abbreviation
    expected = [
      {
        type: "paragraph",
        content: {
          text: "HTML",
          spans: []
        }
      }]
    markdown = "HTML\n\n*[HTML]: test"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_comment
    expected = []
    markdown = "{::comment}\nComment\n{:/comment}"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_xml_comment
    expected = []
    markdown = "<!-- a *comment* -->"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_xml_pi
    expected = []
    markdown = "<? a processing `instruction`?>"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end

  def test_convert_raw
    expected = []
    markdown = "{::nomarkdown}\nComment\n{:/nomarkdown}"
    doc = Kramdown::Document.new(markdown, input: :kramdown)
    assert_equal expected, doc.to_prismic
    assert_equal 1, doc.warnings.size
  end
end
