require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'
require 'ostruct'

class ImagesFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::ImagesFilter

  IMG_SRC = 'http://example.com/img.png'
  IMG_BODY = '<img src="http://example.com/img.png">'

  before do
    Docs::ImagesFilter.cache.clear
    context[:optimize_images] = false
  end

  def make_response(success: true, mime_type: 'image/png', content_length: 100, body: 'imgdata', code: 200)
    OpenStruct.new(success?: success, mime_type: mime_type, content_length: content_length, body: body, code: code)
  end

  def stub_request(response)
    stub(Docs::Request).run { |_url, &block| block.call(response) }
  end

  context "when download_images is false" do
    it "returns doc unchanged and makes no requests" do
      context[:download_images] = false
      @body = IMG_BODY
      dont_allow(Docs::Request).run
      assert_equal IMG_SRC, filter_output.at_css('img')['src']
    end
  end

  context "with a data: URL" do
    it "skips the image and makes no request" do
      @body = '<img src="data:image/png;base64,aaaaaa2320345bbb234">'
      dont_allow(Docs::Request).run
      assert_equal 'data:image/png;base64,aaaaaa2320345bbb234', filter_output.at_css('img')['src']
    end
  end

  context "with a non-http(s) URL" do
    it "skips the image and makes no request" do
      @body = '<img src="ftp://example.com/img.png">'
      dont_allow(Docs::Request).run
      filter_output
    end
  end

  context "with a successful image response" do
    it "replaces src with a base64 data URI" do
      @body = IMG_BODY
      stub_request make_response(body: 'imgdata', mime_type: 'image/png', content_length: 7)
      expected = "data:image/png;base64,#{Base64.strict_encode64('imgdata')}"
      assert_equal expected, filter_output.at_css('img')['src']
    end

    it "caches the data URI for subsequent calls" do
      @body = IMG_BODY
      stub_request make_response(body: 'imgdata', mime_type: 'image/png', content_length: 7)
      filter_output
      assert Docs::ImagesFilter.cache.key?(IMG_SRC)
      assert Docs::ImagesFilter.cache[IMG_SRC].start_with?('data:')
    end
  end

  context "when response is not successful" do
    it "instruments broken.image" do
      @body = IMG_BODY
      stub_request make_response(success: false, code: 404)
      @called = false
      filter.subscribe('broken.image') { @called = true }
      filter_output
      assert @called
    end

    it "does not alter the src" do
      @body = IMG_BODY
      stub_request make_response(success: false, code: 404)
      assert_equal IMG_SRC, filter_output.at_css('img')['src']
    end
  end

  context "when response mime type is not image/" do
    it "instruments invalid.image" do
      @body = IMG_BODY
      stub_request make_response(mime_type: 'text/html')
      @called = false
      filter.subscribe('invalid.image') { @called = true }
      filter_output
      assert @called
    end
  end

  context "when an exception is raised during the request" do
    it "instruments error.image" do
      @body = IMG_BODY
      stub(Docs::Request).run { raise 'connection error' }
      @called = false
      filter.subscribe('error.image') { @called = true }
      filter_output
      assert @called
    end
  end

  context "with a cached src" do
    it "uses the cached data URI without making a request" do
      cached = "data:image/png;base64,#{Base64.strict_encode64('cached')}"
      Docs::ImagesFilter.cache[IMG_SRC] = cached
      @body = IMG_BODY
      dont_allow(Docs::Request).run
      assert_equal cached, filter_output.at_css('img')['src']
    end

    it "leaves src unchanged when cache marks the URL as failed" do
      Docs::ImagesFilter.cache[IMG_SRC] = false
      @body = IMG_BODY
      dont_allow(Docs::Request).run
      assert_equal IMG_SRC, filter_output.at_css('img')['src']
    end
  end

  context "when optimize_images is not disabled" do
    it "passes image data through optimize_image_data" do
      @body = IMG_BODY
      optimized = 'optimized_imgdata'
      stub_request make_response(body: 'imgdata', mime_type: 'image/png', content_length: 7)
      stub(Docs::ImagesFilter).optimize_image_data('imgdata') { optimized }
      context.delete(:optimize_images)
      expected = "data:image/png;base64,#{Base64.strict_encode64(optimized)}"
      assert_equal expected, filter_output.at_css('img')['src']
    end
  end
end
