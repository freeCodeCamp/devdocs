require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsResponseCacheTest < Minitest::Spec
  let :path do
    File.join tmp_path, 'response_cache'
  end

  let :cache do
    Docs::ResponseCache.new path
  end

  let :request do
    Docs::Request.new 'http://example.com/page', cache: cache
  end

  let :response do
    Typhoeus::Response.new(
      code: 200,
      headers: { 'Content-Type' => 'text/html' },
      body: '<html></html>',
      effective_url: 'http://example.com/page',
      return_code: :ok
    ).tap { |response| response.extend Docs::Response }
  end

  after do
    FileUtils.rm_rf path
  end

  describe "#set" do
    it "stores the response" do
      cache.set request, response
      assert File.exist?(cache.path_for(request))
    end

    it "marks the directory as a scraper cache" do
      cache.set request, response
      assert File.exist?(File.join(path, Docs::ResponseCache::MARKER_FILENAME))
    end

    it "ignores mocked responses" do
      response.mock = true
      cache.set request, response
      refute File.exist?(cache.path_for(request))
    end

    it "ignores unsuccessful responses" do
      response.options[:code] = 404
      cache.set request, response
      refute File.exist?(cache.path_for(request))
    end

    it "ignores responses that came from the cache" do
      response.cached = true
      cache.set request, response
      refute File.exist?(cache.path_for(request))
    end
  end

  describe "#get" do
    it "returns nil when nothing is stored for the request" do
      assert_nil cache.get(request)
    end

    it "returns the stored response" do
      cache.set request, response
      result = cache.get(request)
      assert_equal response.code, result.code
      assert_equal response.body, result.body
      assert_equal response.headers.to_h, result.headers.to_h
      assert_equal response.effective_url.to_s, result.effective_url
      assert result.cached?
    end

    it "returns nil when the stored response can't be read" do
      cache.set request, response
      File.binwrite cache.path_for(request), 'garbage'
      assert_nil cache.get(request)
    end
  end

  describe ".clean" do
    before do
      @cache_path = Docs.cache_path
      Docs.cache_path = File.join(tmp_path, 'cache')
    end

    after do
      FileUtils.rm_rf Docs.cache_path
      Docs.cache_path = @cache_path
    end

    it "deletes the scraper caches" do
      cache = Docs::ResponseCache.new(File.join(Docs.cache_path, 'scraper'))
      cache.set request, response
      Docs::ResponseCache.clean
      refute File.exist?(cache.path)
    end

    it "leaves other directories alone" do
      other = File.join(Docs.cache_path, 'assets')
      FileUtils.mkdir_p other
      Docs::ResponseCache.clean
      assert File.exist?(other)
    end
  end
end
