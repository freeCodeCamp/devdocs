require 'test_helper'
require 'docs'

class NormalizeUrlsFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::NormalizeUrlsFilter

  before do
    context[:url] = 'http://example.com/dir/file'
  end

  it "rewrites relative urls" do
    @body = link_to './path'
    assert_equal link_to('http://example.com/dir/path'), filter_output_string
  end

  it "rewrites root-relative urls" do
    @body = link_to '/path'
    assert_equal link_to('http://example.com/path'), filter_output_string
  end

  it "rewrites relative image urls" do
    @body = '<img src="/image.png">'
    assert_equal '<img src="http://example.com/image.png">', filter_output_string
  end

  it "rewrites relative iframe urls" do
    @body = '<iframe src="/path"></iframe>'
    assert_equal '<iframe src="http://example.com/path"></iframe>', filter_output_string
  end

  it "rewrites protocol-less urls" do
    @body = link_to '//example.com/'
    assert_equal link_to('http://example.com/'), filter_output_string
  end

  it "rewrites empty urls" do
    @body = link_to ''
    assert_equal link_to(context[:url]), filter_output_string
  end

  it "rewrites invalid link urls" do
    @body = link_to '%'
    assert_equal link_to('#'), filter_output_string
  end

  it "rewrites invalid image urls" do
    @body = '<img src="%">'
    assert_equal '<img src="#">', filter_output_string
  end

  it "doesn't rewrite invalid iframe urls" do
    @body = '<iframe src="%"></iframe>'
    assert_equal @body, filter_output_string
  end

  it "repairs un-encoded spaces" do
    @body = link_to 'http://example.com/#foo bar '
    assert_equal link_to('http://example.com/#foo%20bar'), filter_output_string
  end

  it "retains query strings" do
    @body = link_to'path?query'
    assert_equal link_to('http://example.com/dir/path?query'), filter_output_string
  end

  it "retains fragments" do
    @body = link_to 'path#frag'
    assert_equal link_to('http://example.com/dir/path#frag'), filter_output_string
  end

  it "doesn't rewrite absolute urls" do
    @body = link_to 'http://not.example.com/path'
    assert_equal @body, filter_output_string
  end

  it "doesn't rewrite fragment-only urls" do
    @body = link_to '#frag'
    assert_equal @body, filter_output_string
  end

  it "doesn't rewrite email urls" do
    @body = link_to 'mailto:test@example.com'
    assert_equal @body, filter_output_string
  end

  it "doesn't rewrite data image urls" do
    @body = '<img src="data:image/gif;base64,aaaa">'
    assert_equal @body, filter_output_string
  end

  context "when context[:replace_paths] is a hash" do
    before do
      context[:base_url] = 'http://example.com/dir/'
      @body = link_to 'http://example.com/dir/path?query#frag'
    end

    it "fixes each absolute url whose subpath is found in the hash" do
      context[:replace_paths] = { 'path' => 'fixed' }
      @body += link_to 'path?query#frag'
      assert_equal link_to('http://example.com/dir/fixed?query#frag') * 2, filter_output_string
    end

    it "doesn't fix urls whose subpath isn't found in the hash" do
      context[:replace_paths] = { 'dir/path' => 'fixed', '/dir/path' => 'fixed' }
      assert_equal @body, filter_output_string
    end

    it "doesn't fix urls whose subpath isn't found in the hash" do
      context[:replace_paths] = {}
      @body = link_to 'http://example.com/dir/path'
      assert_equal @body, filter_output_string
    end
  end

  context "when context[:replace_urls] is a hash" do
    before do
      @body = link_to 'http://example.com/path?#'
    end

    it "replaces each absolute url found in the hash" do
      context[:replace_urls] = { 'http://example.com/path?#' => 'fixed' }
      @body += link_to '/path?#'
      assert_equal link_to('fixed') * 2, filter_output_string
    end

    it "doesn't replace urls not found in the hash" do
      context[:replace_urls] = {}
      assert_equal @body, filter_output_string
    end
  end

  context "when context[:fix_urls_before_parse] is a block" do
    before do
      @body = link_to 'foo[bar]'
    end

    it "calls the block with each absolute url" do
      context[:fix_urls_before_parse] = ->(arg) { (@args ||= []).push(arg); nil }
      @body += link_to 'foo[bar]'
      filter.call
      assert_equal ['foo[bar]'] * 2, @args
    end

    it "replaces the url with the block's return value" do
      context[:fix_urls_before_parse] = ->(url) { '/fixed' }
      assert_equal link_to('http://example.com/fixed'), filter_output_string
    end
  end

  context "when context[:fix_urls] is a block" do
    before do
      @body = link_to 'http://example.com/path?#'
    end

    it "calls the block with each absolute url" do
      context[:fix_urls] = ->(arg) { (@args ||= []).push(arg); nil }
      @body += link_to '/path?#'
      filter.call
      assert_equal ['http://example.com/path?#'] * 2, @args
    end

    it "replaces the url with the block's return value" do
      context[:fix_urls] = ->(url) { url == 'http://example.com/path?#' ? 'fixed' : url }
      assert_equal link_to('fixed'), filter_output_string
    end

    it "doesn't replace the url when the block returns nil" do
      context[:fix_urls] = ->(_) { nil }
      assert_equal @body, filter_output_string
    end

    it "skips fragment-only urls" do
      context[:fix_urls] = ->(_) { @called = true }
      @body = link_to '#frag'
      filter.call
      refute @called
    end
  end

  context "when context[:redirections] is a hash" do
    before do
      @body = link_to 'http://example.com/path?query#frag'
    end

    it "replaces the path of matching urls, case-insensitive" do
      @body = link_to('http://example.com/PATH?query#frag') + link_to('http://example.com/path/two')
      context[:redirections] = { '/path' => '/fixed' }
      expected = link_to('http://example.com/fixed?query#frag') + link_to('http://example.com/path/two')
      assert_equal expected, filter_output_string
    end

    it "does a multi pass with context[:fix_urls]" do
      @body = link_to('http://example.com/path')
      context[:fix_urls] = ->(url) do
        url.sub! 'example.com', 'example.org'
        url.sub! '/Fixed', '/fixed'
        url
      end
      context[:redirections] = { '/path' => '/Fixed' }
      assert_equal link_to('http://example.org/fixed'), filter_output_string
    end
  end
end
