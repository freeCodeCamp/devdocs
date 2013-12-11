require 'test_helper'
require 'docs'

class FileScraperTest < MiniTest::Spec
  class Scraper < Docs::FileScraper
    self.dir = '/'
    self.html_filters = Docs::FilterStack.new
    self.text_filters = Docs::FilterStack.new
  end

  let :scraper do
    Scraper.new
  end

  let :response do
    OpenStruct.new body: 'body', url: Docs::URL.parse(Scraper.base_url)
  end

  describe ".inherited" do
    it "sets .base_url" do
      assert_equal Scraper.base_url, Class.new(Scraper).base_url
    end
  end

  describe "#request_one" do
    let :path do
      File.join(Scraper.dir, 'path')
    end

    let :result do
      scraper.send :request_one, path
    end

    before do
      stub(scraper).read_file
    end

    it "reads a file" do
      mock(scraper).read_file(path)
      result
    end

    describe "the returned response object" do
      it "has a #body" do
        stub(scraper).read_file { 'body' }
        assert_equal 'body', result.body
      end

      it "has a #url" do
        assert_equal path, result.url.to_s
        assert_instance_of Docs::URL, result.url
      end
    end
  end

  describe "#request_all" do
    let :urls do
      %w(one two)
    end

    it "requests the given url" do
      mock(scraper).request_one('url')
      scraper.send(:request_all, 'url') {}
    end

    it "requests the given urls" do
      requests = []
      stub(scraper).request_one { |url| requests << url; nil }
      scraper.send(:request_all, urls) {}
      assert_equal urls, requests
    end

    it "yields the responses" do
      responses = []
      stub(scraper).request_one { |url| urls.index(url) }
      scraper.send(:request_all, urls) { |response| responses << response; nil }
      assert_equal (0...urls.length).to_a, responses
    end

    context "when the block returns an array" do
      let :next_urls do
        %w(three four)
      end

      let :all_urls do
        urls + %w(three four)
      end

      it "requests the returned urls" do
        requests = []
        stub(scraper).request_one { |url| requests << url; url }
        scraper.send(:request_all, urls) { [next_urls.shift].compact }
        assert_equal all_urls, requests
      end

      it "yields their responses" do
        responses = []
        stub(scraper).request_one { |url| all_urls.index(url) }
        scraper.send :request_all, urls do |response|
          responses << response
          [next_urls.shift].compact
        end
        assert_equal (0...all_urls.length).to_a, responses
      end
    end
  end

  describe "#process_response?" do
    let :result do
      scraper.send :process_response?, response
    end

    it "returns false when the response body is blank" do
      response.body = ''
      refute result
    end

    it "returns true when the response body isn't blank" do
      response.body = 'body'
      assert result
    end
  end

  describe "#read_file" do
    let :result do
      scraper.send :read_file, 'file'
    end

    it "returns the file's content when the file exists" do
      stub(File).read('file') { 'content' }
      assert_equal 'content', result
    end

    it "returns nil when the file doesn't exist" do
      stub(File).read('file') { raise }
      assert_nil result
    end
  end
end
