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
    it "requests the given url and yields the response" do
      stub(scraper).request_one('url') { 'response' }
      scraper.send(:request_all, 'url') { |response| @response = response }
      assert_equal 'response', @response
    end

    describe "when the block returns an array" do
      it "requests and yields the returned urls" do
        stub(scraper).request_one('one') { 1 }
        stub(scraper).request_one('two') { 2 }
        stub(scraper).request_one('three') { 3 }
        scraper.send :request_all, 'one' do |response|
          if response == 1
            ['two']
          elsif response == 2
            ['three']
          else
            @response = response
          end
        end
        assert_equal 3, @response
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
