# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = 'kramdown-prismic'
  s.version     = '0.0.1'
  s.summary     = ""
  s.description = ""
  s.authors     = ["François de Metz"]
  s.email       = 'francois@2metz.fr'
  s.files       = ["lib/kramdown-prismic.rb"]
  s.homepage    = 'https://github.com/stormz/kramdown-prismic'
  s.license     = 'MIT'

  s.add_dependency "kramdown", "~> 1.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rake", "~> 12.0"
end

