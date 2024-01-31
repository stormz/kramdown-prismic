# frozen_string_literal: true

require "json"

require "minitest/autorun"
require 'minitest/match_json'

require "kramdown-prismic"


class KramdownPrismicImportApiConverterTest < Minitest::Test
  def test_from_html_to_prismic_v1
    document = Kramdown::Document.new(fixture("web.html"), :input => :html)
    expected = JSON.parse(fixture("import-api.json"), :symbolize_names => true)

    assert_match_json expected, document.to_prismic
  end

  def test_from_html_to_prismic_v2
    document = Kramdown::Document.new(fixture("web.html"), :input => :html)
    expected = JSON.parse(fixture("migration-api.json"), :symbolize_names => true)

    assert_match_json expected, document.to_prismic_v2
  end

  def test_from_markdown_to_prismic_v1
    document = Kramdown::Document.new(fixture("markdown.md"), :input => :markdown)
    expected = JSON.parse(fixture("import-api.json"), :symbolize_names => true)
    result = document.to_prismic

    result.each do |element|
      if (text = element.dig(:content, :text))
        element[:content][:text] = text.gsub(/\n/, " ")
      end
    end

    assert_match_json expected, result
  end

  def test_from_markdown_to_prismic_v2
    document = Kramdown::Document.new(fixture("markdown.md"), :input => :markdown)
    expected = JSON.parse(fixture("migration-api.json"), :symbolize_names => true)
    result = document.to_prismic_v2

    result.each do |element|
      if (text = element[:text])
        element[:text] = text.gsub(/\n/, " ")
      end
    end

    assert_match_json expected, result
  end

  def test_from_prismic_v1_to_markdown
    document = Kramdown::Document.new(JSON.parse(fixture("import-api.json"), :symbolize_names => true), :input => :prismic)
    expected = fixture("markdown.md")

    assert_match expected, document.to_kramdown
  end

  def test_from_prismic_v2_to_markdown
    document = Kramdown::Document.new(JSON.parse(fixture("migration-api.json"), :symbolize_names => true), :input => :prismic_v2)
    expected = fixture("markdown.md")

    assert_match expected, document.to_kramdown
  end

  protected

  def fixture(name)
    File.read(File.expand_path(File.join("fixtures", name), __dir__))
  end
end
