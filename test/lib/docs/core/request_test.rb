require 'test_helper'
require 'docs'

class DocsRequestTest < MiniTest::Spec
  let :url do
    'http://example.com'
  end

  def request(url = self.url, options = {})
    Docs::Request.new(url, options).tap do |request|
      request.extend FakeInstrumentation
    end
  end

  let :response do
    Typhoeus::Response.new.tap do |response|
      Typhoeus.stub(url).and_return(response)
    end
  end

  after do
    Typhoeus::Expectation.clear
  end

  describe ".run" do
    before { response }

    it "makes a request and returns the response" do
      assert_equal response, Docs::Request.run(url)
    end

    it "calls the given block with the response" do
      Docs::Request.run(url) { |arg| @arg = arg }
      assert_equal response, @arg
    end
  end

  describe ".new" do
    it "accepts a Docs::URL" do
      url = Docs::URL.parse 'http://example.com'
      assert_equal url.to_s, request(url).base_url
    end

    it "defaults :followlocation to true" do
      assert request.options[:followlocation]
      refute request(url, followlocation: false).options[:followlocation]
    end
  end

  describe "#run" do
    before { response }

    it "instruments 'response'" do
      req = request.tap(&:run)
      assert req.last_instrumentation
      assert_equal 'response.request', req.last_instrumentation[:event]
      assert_equal url, req.last_instrumentation[:payload][:url]
      assert_equal response, req.last_instrumentation[:payload][:response]
    end
  end

  describe "#response=" do
    it "extends the object with Docs::Response" do
      response = Object.new
      request.response = response
      assert_includes response.singleton_class.ancestors, Docs::Response
    end
  end
end
