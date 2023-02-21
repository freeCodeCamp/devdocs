require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class DocsUrlScraperTest < MiniTest::Spec
  class Scraper < Docs::UrlScraper
    self.base_url = 'http://example.com'
    self.html_filters = Docs::FilterStack.new
    self.text_filters = Docs::FilterStack.new
  end

  let :scraper do
    Scraper.new
  end

  describe ".inherited" do
    it "duplicates .params" do
      stub(Scraper).params { { test: [] } }
      subclass = Class.new Scraper
      assert_equal Scraper.params, subclass.params
      refute_same Scraper.params, subclass.params
      refute_same Scraper.params[:test], subclass.params[:test]
    end
  end

  describe "#request_one" do
    let :result do
      scraper.send :request_one, 'url'
    end

    it "runs a Request with the given url" do
      mock(Docs::Request).run 'url', anything
      result
    end

    it "runs a Request with the .params" do
      stub(Scraper).params { { test: true } }
      mock(Docs::Request).run anything, satisfy { |options| options[:params][:test] }
      result
    end

    it "returns the result" do
      stub(Docs::Request).run { 'response' }
      assert_equal 'response', result
    end
  end

  describe "#request_all" do
    let :block do
      Proc.new {}
    end

    let :result do
      scraper.send :request_all, 'urls', &block
    end

    it "runs a Requester with the given urls" do
      mock(Docs::Requester).run('urls', request_options: {params: {}, headers: {"User-Agent" => "DevDocs"}})
      result
    end

    it "runs a Requester with .headers as :request_options" do
      stub(Scraper).headers { { testheader: true } }
      mock(Docs::Requester).run('urls', request_options: {params: {}, headers: {testheader: true}})
      result
    end

    it "runs a Requester with default .headers as :request_options" do
      mock(Docs::Requester).run('urls', request_options: {params: {}, headers: {"User-Agent" => "DevDocs"}})
      result
    end

    it "runs a Requester with .params as :request_options" do
      stub(Scraper).params { { test: true } }
      mock(Docs::Requester).run('urls', request_options: {params: {test: true}, headers: {"User-Agent" => "DevDocs"}})
      result
    end

    it "runs a Requester with the given block" do
      stub(Docs::Requester).run { |*_args, **_kwargs, &block| @block = block }
      result
      assert_equal block, @block
    end

    it "returns the result" do
      stub(Docs::Requester).run { 'response' }
      assert_equal 'response', result
    end
  end

  describe "#process_response?" do
    let :response do
      OpenStruct.new success?: true, html?: true, effective_url: scraper.root_url, error?: false
    end

    let :result do
      scraper.send :process_response?, response
    end

    it "raises when the response is an error" do
      response.send 'error?=', true
      assert_raises(RuntimeError) { result }
    end

    it "returns false when the response isn't successful" do
      response.send 'success?=', false
      refute result
    end

    it "returns false when the response isn't HTML" do
      response.send 'html?=', false
      refute result
    end

    it "returns false when the response's effective url isn't in the base url" do
      response.effective_url = 'http://not.example.com'
      refute result
    end

    it "returns true otherwise" do
      assert result
    end
  end
end
