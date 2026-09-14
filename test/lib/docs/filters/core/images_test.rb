require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'
require 'ostruct'
require 'chunky_png'

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

  # A small gradient; lossless WebP compresses it well below the PNG.
  def png_data
    ChunkyPNG::Image.new(64, 64).tap do |image|
      64.times { |x| 64.times { |y| image[x, y] = ChunkyPNG::Color.rgb(x * 4, y * 4, 128) } }
    end.to_blob
  end

  def fixture(name)
    File.binread(File.expand_path("../../../../files/#{name}", __dir__))
  end

  # Splices an acTL chunk before IDAT to mimic an animated PNG.
  def apng_data
    data = png_data
    offset = data.index('IDAT'.b) - 4
    chunk = [8].pack('N') + 'acTL' + "\0" * 8 + [0].pack('N')
    data.byteslice(0, offset) + chunk + data.byteslice(offset..-1)
  end

  def image_from(src)
    Base64.decode64(src.sub(/\Adata:[^,]+,/, ''))
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

  context "with a PNG image" do
    it "converts it to WebP" do
      @body = IMG_BODY
      data = png_data
      stub_request make_response(body: data, content_length: data.bytesize)
      src = filter_output.at_css('img')['src']
      assert src.start_with?('data:image/webp;base64,'), src[0, 40]
      webp = image_from(src)
      assert_equal 'RIFF', webp.byteslice(0, 4)
      assert_equal 'WEBP', webp.byteslice(8, 4)
      assert_operator webp.bytesize, :<, data.bytesize
    end

    it "checks the converted size, not the PNG size, against max_image_size" do
      @body = IMG_BODY
      data = png_data
      # no Content-Length header (chunked response): only the second check applies
      context[:max_image_size] = data.bytesize - 1
      stub_request make_response(body: data, content_length: 0)
      assert filter_output.at_css('img')['src'].start_with?('data:image/webp;base64,')
    end

    it "keeps the PNG when the conversion doesn't pay off" do
      @body = IMG_BODY
      data = png_data
      stub_request make_response(body: data, content_length: data.bytesize)
      stub(Docs::ImagesFilter).convert_to_webp(data) { nil }
      expected = "data:image/png;base64,#{Base64.strict_encode64(data)}"
      assert_equal expected, filter_output.at_css('img')['src']
    end

    it "skips animated PNGs" do
      assert_nil Docs::ImagesFilter.convert_to_webp(apng_data)
    end
  end

  context "with a GIF image" do
    it "converts it to WebP" do
      @body = IMG_BODY
      data = fixture('image.gif')
      stub_request make_response(body: data, mime_type: 'image/gif', content_length: data.bytesize)
      src = filter_output.at_css('img')['src']
      assert src.start_with?('data:image/webp;base64,'), src[0, 40]
      webp = image_from(src)
      assert_equal 'RIFF', webp.byteslice(0, 4)
      assert_equal 'WEBP', webp.byteslice(8, 4)
      assert_operator webp.bytesize, :<, data.bytesize
    end

    it "recognizes the GIF87a signature" do
      assert Docs::ImagesFilter.convert_to_webp(fixture('image.gif').sub('GIF89a', 'GIF87a'))
    end
  end

  context "with a JPEG image" do
    it "converts it to WebP" do
      @body = IMG_BODY
      data = fixture('image.jpg')
      stub_request make_response(body: data, mime_type: 'image/jpeg', content_length: data.bytesize)
      src = filter_output.at_css('img')['src']
      assert src.start_with?('data:image/webp;base64,'), src[0, 40]
      webp = image_from(src)
      assert_equal 'RIFF', webp.byteslice(0, 4)
      assert_equal 'WEBP', webp.byteslice(8, 4)
      assert_operator webp.bytesize, :<, data.bytesize
    end

    it "encodes it lossily" do
      assert_equal Docs::ImagesFilter::CWEBP_LOSSY_COMMAND,
                   Docs::ImagesFilter.webp_command(fixture('image.jpg'))
    end
  end

  context "with an image we can't convert" do
    it "is left untouched" do
      @body = IMG_BODY
      stub_request make_response(body: 'imgdata', mime_type: 'image/bmp', content_length: 7)
      expected = "data:image/bmp;base64,#{Base64.strict_encode64('imgdata')}"
      assert_equal expected, filter_output.at_css('img')['src']
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
