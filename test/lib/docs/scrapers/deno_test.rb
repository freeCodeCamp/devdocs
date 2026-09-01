require_relative '../../test_helper'

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
