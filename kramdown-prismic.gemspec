# encoding: utf-8
require File.expand_path('../lib/kramdown-prismic/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'kramdown-prismic'
  s.version     = KramdownPrismic::VERSION
  s.summary     = "A Kramdown converter to convert documents into prismic rich text format."
  s.description = "A Kramdown converter to convert documents into prismic rich text format."
  s.authors     = ["François de Metz"]
  s.email       = 'francois@2metz.fr'
  s.files       = ["lib/kramdown-prismic.rb"]
  s.homepage    = 'https://github.com/stormz/kramdown-prismic'
  s.license     = 'MIT'

  s.add_dependency "kramdown", "~> 1.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 12.0"
end
