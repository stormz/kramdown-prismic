# Kramdown Prismic

A [Kramdown][] converter to convert documents into [prismic][] rich text format.

Thanks to kramdown, you can convert HTML, Kramdown and markdown documents to the prismic format.

## Install

```ruby
gem 'kramdown-prismic', '~> 0.1'
```

## Usage

### Convert kramdown documents to Prismic

```ruby
require 'kramdown-prismic'

kramdown = '# Hello world'
Kramdown::Document.new(kramdown).to_prismic
```

### Convert markdown documents to Prismic

```ruby
require 'kramdown-prismic'

markdown = '# Hello world'
Kramdown::Document.new(markdown, input: :markdown).to_prismic
```

### Convert HTML documents to Prismic

```ruby
require 'kramdown-prismic'

html = '<h1>Hello world</h1>'
Kramdown::Document.new(html, input: :html).to_prismic
```

### Lookup for warnings

If there is some elements that cannot be converted (see the status table), a warning will be emitted.

For instance, html elements in the markdown is not supported:

```ruby
require 'kramdown-prismic'

markdown = '<h1>Hello world</h1>'
result = Kramdown::Document.new(markdown, input: :markdown)
result.to_prismic
p result.warnings
```

### Difference between markdown and rich text

Some elements cannot be converted, due to some Prismic limitations. The table below explain the difference and limitations of the current converter:

| Markdown         | Prismic                    |
|------------------|----------------------------|
| blockquote       | converted to preformatted  |
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
| entity           | converted to unicode     |
| typographic_sym  | converted to unicode     |
| smart_quote      | converted to unicode     |
| abbreviation     | not supported              |
| html_element     | not supported              |
| xml_comment      | not supported              |
| xml_pi           | not supported              |
| comment          | not supported              |
| raw              | not supported              |

## License

MIT

[Kramdown]: https://kramdown.gettalong.org/
[prismic]: https://prismic.io/
