# Kramdown Prismic

A Kramdown converter to convert documents into prismic rich text format.

## Status

*Very early*, still a proof of concept.

TODO:

- [x] heading1
- [x] heading2
- [x] heading3
- [x] heading4
- [x] heading5
- [x] heading6
- [x] paragraph
- [x] preformatted
- [x] strong
- [x] em
- [x] hyperlink
- [x] o-list-item
- [x] list-item
- [ ] Image
- [ ] Embed

## Difference between markdown and rich text

| Markdown     | Prismic                    |
|--------------|----------------------------|
| Blockquote   | translated to preformatted |
| hr           | nothing                    |

## Install

Not yet available on rubygems

## Usage

```ruby
require 'kramdown-prismic'

Kramdown::Document.new(markdown).to_prismic
```

## License

MIT
