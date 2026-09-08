require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DenoScraperTest < Minitest::Test
  def setup
    @scraper_class = Docs::Deno
  end

  def test_scraper_name
    assert_equal 'Deno', @scraper_class.name
  end

  def test_scraper_type
    assert_equal 'deno', @scraper_class.type
  end

  def test_base_url
    assert_equal 'https://docs.deno.com/', @scraper_class.base_url
  end

  def test_root_path
    assert_equal 'api/', @scraper_class.root_path
  end

  def test_initial_paths_present
    assert_kind_of Array, @scraper_class.initial_paths
    refute_empty @scraper_class.initial_paths
    assert_includes @scraper_class.initial_paths, 'api/'
    assert_includes @scraper_class.initial_paths, 'runtime/'
  end

  def test_links_defined
    links = @scraper_class.links
    assert_kind_of Hash, links
    assert links.key?(:home)
    assert links.key?(:code)
    assert_match %r{\Ahttps://}, links[:home]
    assert_match %r{github\.com}, links[:code]
  end

  def test_only_patterns_defined
    patterns = @scraper_class.options[:only_patterns]
    assert_kind_of Array, patterns
    refute_empty patterns
    assert patterns.any? { |p| p.is_a?(Regexp) }
  end

  def test_skip_patterns_excludes_blog
    patterns = @scraper_class.options[:skip_patterns]
    assert_kind_of Array, patterns
    assert patterns.any? { |p| 'blog/foo' =~ p }
  end

  def test_skip_patterns_excludes_deploy
    patterns = @scraper_class.options[:skip_patterns]
    assert patterns.any? { |p| 'deploy/docs' =~ p }
  end

  def test_attribution_present
    attribution = @scraper_class.options[:attribution]
    assert_kind_of String, attribution
    refute_empty attribution.strip
    assert_match(/Deno/, attribution)
  end

  def test_has_versions
    versions = @scraper_class.versions
    refute_nil versions
    refute_empty versions
  end

  def test_module_categories_frozen
    categories = Docs::Deno::MODULE_CATEGORIES
    assert categories.frozen?
    assert_kind_of Hash, categories
    assert categories.key?('Deno')
    assert categories.key?('Web APIs')
    assert categories.key?('File System')
    assert categories.key?('Network')
  end

  def test_inherits_from_url_scraper
    assert @scraper_class < Docs::UrlScraper
  end
end

class DenoEntriesFilterTest < Minitest::Test
  def test_extracts_api_entry_from_content_heading
    entry = filter_fixture('deno_api.html', 'api/deno/network/').first

    assert_equal 'Network', entry.name
    assert_equal 'API', entry.type
  end

  def test_extracts_runtime_entry_from_content_heading
    entry = filter_fixture('deno_runtime.html', 'runtime/reference/std/fmt/').first

    assert_equal '@std/fmt', entry.name
    assert_equal 'Runtime', entry.type
  end

  private

  def filter_fixture(name, path)
    html = File.read(File.join(DenoCleanHtmlFilterTest::FIXTURES_PATH, name))
    doc = Docs::Parser.new(html).html
    context = {
      base_url: Docs::URL.parse('https://docs.deno.com/'),
      url: Docs::URL.parse("https://docs.deno.com/#{path}"),
      root_path: 'api/',
    }
    result = { path: path }
    content = Docs::Deno::CleanHtmlFilter.new(doc, context, result).call
    Docs::Deno::EntriesFilter.new(content, context, result).call
    result[:entries]
  end
end

class DenoCleanHtmlFilterTest < Minitest::Test
  FIXTURES_PATH = File.expand_path('../../../files', __dir__)

  def test_cleans_api_page_chrome_and_preserves_content
    output = filter_fixture('deno_api.html')

    assert_equal 'article', output.name
    assert_equal 'Network', output.at_css('h1').content
    assert_includes output.text, 'Deno.connect'
    refute_includes output.text, 'Site navigation'
    refute_includes output.text, 'Did you find what you needed?'
    assert_empty output.css('.breadcrumbs, .docNodeKindIcon, .copyButton')
    assert_equal 'ts', output.at_css('pre')['data-language']
  end

  def test_cleans_runtime_page_chrome_and_preserves_content
    output = filter_fixture('deno_runtime.html')

    assert_equal '@std/fmt', output.at_css('h1').content
    assert_includes output.text, 'Runtime compatibility'
    assert_includes output.text, 'Add to your project'
    assert_includes output.text, 'See all symbols'
    refute_includes output.text, 'On this page'
    refute_includes output.text, 'Copy page'
    refute_includes output.text, 'Did you find what you needed?'
    refute_includes output.text, 'Edit this page'
    assert_empty output.css('.copyButton, a.anchor, nav')
    assert_equal %w(js sh jsonc), output.css('pre').map { |node| node['data-language'] }
  end

  private

  def filter_fixture(name)
    html = File.read(File.join(FIXTURES_PATH, name))
    doc = Docs::Parser.new(html).html
    Docs::Deno::CleanHtmlFilter.new(doc, {}, {}).call
  end
end
