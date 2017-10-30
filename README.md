# Kramdown Prismic

A Kramdown converter to convert documents into prismic rich text format.

## Status

Most of the content is translated. See the table below to see the difference:

### Difference between markdown and rich text

| Markdown         | Prismic                    |
|------------------|----------------------------|
| Blockquote       | translated to preformatted |
| hr               | nothing                    |
| img              | moved to the top level     |
| nested list      | moved to the top level     |
| dl               | not supported              |
| dt               | not supported              |
| dd               | not supported              |
| table            | not supported              |
| thead            | not supported              |
| tobdy            | not supported              |
| tfoot            | not supported              |
| tr               | not supported              |
| td               | not supported              |
| math             | not supported              |
| footnote         | not supported              |
| entity           | Transformed to unicode     |
| typographic_sym  | Transformed to unicode     |
| smart_quote      | Transformed to unicode     |
| abbreviation     | not supported              |
| html_element     | not supported              |
| xml_comment      | not supported              |
| xml_pi           | not supported              |
| comment          | not supported              |
| raw              | not supported              |

## Install

```ruby
gem 'kramdown-prismic', '~> 0.1'
```

## Usage

```ruby
require 'kramdown-prismic'

Kramdown::Document.new(markdown).to_prismic
```

## License

MIT
