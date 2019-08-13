require 'test_helper'
require 'docs'

class FileScraperTest < MiniTest::Spec
  ROOT_PATH = File.expand_path('../../../../../../', __FILE__)

  class Scraper < Docs::FileScraper
    self.html_filters = Docs::FilterStack.new
    self.text_filters = Docs::FilterStack.new

    version 'version' do; end
  end

  let :scraper do
    Scraper.new
  end

  let :versioned_scraper do
    Scraper.versions.first.new
  end

  let :response do
    OpenStruct.new body: 'body', url: Docs::URL.parse(Scraper.base_url)
  end

  describe ".inherited" do
    it "sets .base_url" do
      assert_equal Scraper.base_url, Class.new(Scraper).base_url
    end
  end

  describe "#source_directory" do
    it "returns the directory at docs/[slug]" do
      assert_equal File.join(ROOT_PATH, 'docs', 'scraper'), scraper.source_directory
      assert_equal File.join(ROOT_PATH, 'docs', 'scraper~version'), versioned_scraper.source_directory
    end
  end

  describe "#request_one" do
    let :path do
      'path'
    end

    let :result do
      scraper.send :request_one, path
    end

    before do
      stub(scraper).read_file
    end

    context "when the source directory doesn't exist" do
      it "raises an error" do
        assert_raises Docs::SetupError do
          result
        end
      end
    end

    context "when the source directory exists" do
      before do
        stub(scraper).assert_source_directory_exists
      end

      it "reads a file" do
        mock(scraper).read_file(File.join(ROOT_PATH, 'docs/scraper', path))
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
  end

  describe "#request_all" do
    let :urls do
      %w(one two)
    end

    context "when the source directory doesn't exist" do
      it "raises an error" do
        assert_raises Docs::SetupError do
          scraper.send(:request_all, urls) {}
        end
      end
    end

    context "when the source directory exists" do
      before do
        stub(scraper).assert_source_directory_exists
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
      scraper.send :read_file, File.join(ROOT_PATH, 'docs', 'scraper', 'file')
    end

    it "returns the file's content when the file exists in the source directory" do
      stub(File).read(File.join(ROOT_PATH, 'docs', 'scraper', 'file')) { 'content' }
      assert_equal 'content', result
    end

    it "returns nil when the file doesn't exist" do
      stub(File).read(File.join(ROOT_PATH, 'docs', 'scraper', 'file')) { raise }
      assert_nil result
    end
  end
end
