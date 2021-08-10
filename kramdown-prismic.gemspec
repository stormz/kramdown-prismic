# frozen_string_literal: true

require File.expand_path('lib/kramdown-prismic/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'kramdown-prismic'
  s.version     = KramdownPrismic::VERSION
  s.summary     = 'A Kramdown converter to convert documents into prismic rich text format and the other way around.'
  s.description = 'A Kramdown converter to convert documents into prismic rich text format and the other way around.'
  s.authors     = ['François de Metz']
  s.email       = 'francois@2metz.fr'

  s.executables << 'markdown2prismic'
  s.executables << 'html2prismic'
  s.executables << 'prismic2markdown'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- test/*`.split("\n")

  s.homepage    = 'https://github.com/stormz/kramdown-prismic'
  s.license     = 'MIT'

  s.add_dependency 'kramdown', '>= 1', '< 3'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 13.0'
end
