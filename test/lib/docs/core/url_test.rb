require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsUrlTest < MiniTest::Spec
  URL = Docs::URL

  describe ".new" do
    it "works with no arguments" do
      assert_instance_of URL, URL.new
    end

    it "works with a Hash of components" do
      assert_equal '/path', URL.new(path: '/path').to_s
    end

    it "raises an error with an invalid component" do
      assert_raises(ArgumentError) { URL.new test: nil }
    end
  end

  describe ".parse" do
    it "returns a URL when given a string" do
      assert_instance_of URL, URL.parse('http://example.com')
    end

    it "returns the same URL when given a URL" do
      url = URL.new
      assert_same url, URL.parse(url)
    end
  end

  describe "#join" do
    it "joins urls" do
      url = URL.parse 'http://example.com/path/to/'
      assert_equal 'http://example.com/path/to/file', url.join('..', 'to/file').to_s
    end
  end

  describe "#merge!" do
    it "works with a Hash of components" do
      assert_equal '/path', URL.new.merge!(path: '/path').to_s
    end

    it "raises an error with an invalid component" do
      assert_raises(ArgumentError) { URL.new.merge! test: nil }
    end
  end

  describe "#origin" do
    it "returns 'http://example.com' when the URL is 'http://example.com/path?#'" do
      assert_equal 'http://example.com', URL.parse('http://example.com/path?#').origin
    end

    it "returns 'http://example.com' when the URL is 'HTTP://EXAMPLE.COM'" do
      assert_equal 'http://example.com', URL.parse('HTTP://EXAMPLE.COM').origin
    end

    it "returns 'http://example.com:8080' when the URL is 'http://example.com:8080'" do
      assert_equal 'http://example.com:8080', URL.parse('http://example.com:8080').origin
    end

    it "returns nil when the URL is 'example.com'" do
      assert_nil URL.parse('example.com').origin
    end

    it "returns nil when the URL is 'mailto:test@example.com'" do
      assert_nil URL.parse('mailto:test@example.com').origin
    end
  end

  describe "#normalized_path" do
    it "returns '/' when the URL is ''" do
      assert_equal '/', URL.parse('').normalized_path
    end

    it "returns '/path' when the URL is '/path'" do
      assert_equal '/path', URL.parse('/path').normalized_path
    end
  end

  describe "#subpath_to" do
    context "when the URL is '/'" do
      let :url do
        URL.parse '/'
      end

      it "returns nil with ''" do
        assert_nil url.subpath_to('')
      end

      it "returns '' with '/'" do
        assert_equal '', url.subpath_to('/')
      end

      it "returns 'path' with '/path'" do
        assert_equal 'path', url.subpath_to('/path')
      end

      it "returns nil with 'path'" do
        assert_nil url.subpath_to('path')
      end

      it "returns nil with 'http://example.com/'" do
        assert_nil url.subpath_to('http://example.com/')
      end
    end

    context "when the URL is '/path/to'" do
      let :url do
        URL.parse '/path/to'
      end

      it "returns nil with '/path/'" do
        assert_nil url.subpath_to('/path/')
      end

      it "returns '' with '/path/to'" do
        assert_equal '', url.subpath_to('/path/to')
      end

      it "returns '/file' with '/path/to/file'" do
        assert_equal '/file', url.subpath_to('/path/to/file')
      end

      it "returns nil with 'path/to/file'" do
        assert_nil url.subpath_to('path/to/file')
      end

      it "returns nil with '/path/tofile'" do
        assert_nil url.subpath_to('/path/tofile')
      end

      it "returns nil with '/PATH/to/file'" do
        assert_nil url.subpath_to('/PATH/to/file')
      end

      context "and :ignore_case is true" do
        it "returns '/file' with '/PATH/to/file'" do
          assert_equal '/file', url.subpath_to('/PATH/to/file', ignore_case: true)
        end
      end
    end

    context "when the URL is '/path/to/'" do
      let :url do
        URL.parse '/path/to/'
      end

      it "returns nil with '/path/to'" do
        assert_nil url.subpath_to('/path/to')
      end

      it "returns 'file' with '/path/to/file'" do
        assert_equal 'file', url.subpath_to('/path/to/file')
      end
    end

    context "when the URL is 'path/to'" do
      let :url do
        URL.parse 'path/to'
      end

      it "returns nil with '/path/to'" do
        assert_nil url.subpath_to('/path/to')
      end

      it "returns '/file' with 'path/to/file'" do
        assert_equal '/file', url.subpath_to('path/to/file')
      end
    end

    context "when the URL is 'http://example.com'" do
      let :url do
        URL.parse 'http://example.com'
      end

      it "returns '' with 'HTTP://EXAMPLE.COM'" do
        assert_equal '', url.subpath_to('HTTP://EXAMPLE.COM')
      end

      it "returns '/path' with 'http://example.com/path?query#frag'" do
        assert_equal '/path', url.subpath_to('http://example.com/path?query#frag')
      end

      it "returns nil with 'https://example.com/'" do
        assert_nil url.subpath_to('https://example.com/')
      end

      it "returns nil with 'http://not.example.com/'" do
        assert_nil url.subpath_to('http://not.example.com/')
      end
    end

    context "when the URL is 'http://example.com/'" do
      let :url do
        URL.parse 'http://example.com/'
      end

      it "returns nil with 'http://example.com'" do
        assert_nil url.subpath_to('http://example.com')
      end
    end

    context "when the URL is 'http://example.com/path/to'" do
      let :url do
        URL.parse 'http://example.com/path/to'
      end

      it "returns '/file' with 'http://example.com/path/to/file'" do
        assert_equal '/file', url.subpath_to('http://example.com/path/to/file')
      end

      it "returns nil with 'http://example.com/path/tofile'" do
        assert_nil url.subpath_to('http://example.com/path/tofile')
      end

      it "returns nil with '/path/to/file'" do
        assert_nil url.subpath_to('/path/tofile')
      end
    end
  end

  describe "#subpath_from" do
    let :url do
      URL.new
    end

    before do
      any_instance_of URL do |instance|
        stub(instance).subpath_to
      end
    end

    it "returns the given url's #subpath_to to self" do
      any_instance_of URL do |instance|
        stub(instance).subpath_to(url, nil) { 'subpath' }
      end
      assert_equal 'subpath', url.subpath_from('url')
    end

    it "calls #subpath_to with the given options" do
      any_instance_of URL do |instance|
        stub(instance).subpath_to(url, 'options') { 'subpath' }
      end
      assert_equal 'subpath', url.subpath_from('url', 'options')
    end
  end

  describe "#contains?" do
    let :url do
      URL.new
    end

    before do
      stub(url).subpath_to
    end

    it "calls #subpath_to with the given url" do
      mock(url).subpath_to('url', nil)
      url.contains?('url')
    end

    it "calls #subpath_to with the given options" do
      mock(url).subpath_to('url', 'options')
      url.contains?('url', 'options')
    end

    it "returns true when the #subpath_to the given url is a string" do
      stub(url).subpath_to { '' }
      assert url.contains?('url')
    end

    it "returns true when the #subpath_to the given url is nil" do
      stub(url).subpath_to { nil }
      refute url.contains?('url')
    end
  end

  describe "#relative_path_to" do
    context "when the URL is '/'" do
      let :url do
        URL.parse '/'
      end

      it "returns '.' with '/'" do
        assert_equal '.', url.relative_path_to('/')
      end

      it "returns 'file' with '/file'" do
        assert_equal 'file', url.relative_path_to('/file')
      end

      it "returns 'file/' with '/file/'" do
        assert_equal 'file/', url.relative_path_to('/file/')
      end

      it "raises an error with 'file'" do
        assert_raises ArgumentError do
          url.relative_path_to 'file'
        end
      end
    end

    context "when the URL is '/path/to'" do
      let :url do
        URL.parse '/path/to'
      end

      it "returns '../' with '/'" do
        assert_equal '../', url.relative_path_to('/')
      end

      it "returns '../path' with '/path'" do
        assert_equal '../path', url.relative_path_to('/path')
      end

      it "returns '.' with '/path/'" do
        assert_equal '.', url.relative_path_to('/path/')
      end

      it "returns 'to' with '/path/to'" do
        assert_equal 'to', url.relative_path_to('/path/to')
      end

      it "returns '../PATH/to' with '/PATH/to'" do
        assert_equal '../PATH/to', url.relative_path_to('/PATH/to')
      end

      it "returns 'to/' with '/path/to/'" do
        assert_equal 'to/', url.relative_path_to('/path/to/')
      end

      it "returns 'to/file' with '/path/to/file'" do
        assert_equal 'to/file', url.relative_path_to('/path/to/file')
      end

      it "returns 'to/file/' with '/path/to/file/'" do
        assert_equal 'to/file/', url.relative_path_to('/path/to/file/')
      end
    end

    context "when the URL is '/path/to/'" do
      let :url do
        URL.parse '/path/to/'
      end

      it "returns '../../' with ''" do
        assert_equal '../../', url.relative_path_to('')
      end

      it "returns '../../' with '/'" do
        assert_equal '../../', url.relative_path_to('/')
      end

      it "returns '../../path' with '/path'" do
        assert_equal '../../path', url.relative_path_to('/path')
      end

      it "returns '../' with '/path/'" do
        assert_equal '../', url.relative_path_to('/path/')
      end

      it "returns '../to' with '/path/to'" do
        assert_equal '../to', url.relative_path_to('/path/to')
      end

      it "returns '.' with '/path/to/'" do
        assert_equal '.', url.relative_path_to('/path/to/')
      end

      it "returns 'file' with '/path/to/file'" do
        assert_equal 'file', url.relative_path_to('/path/to/file')
      end

      it "returns 'file/' with '/path/to/file/'" do
        assert_equal 'file/', url.relative_path_to('/path/to/file/')
      end
    end

    context "when the URL is 'http://example.com'" do
      let :url do
        URL.parse 'http://example.com'
      end

      it "returns '.' with 'http://example.com'" do
        assert_equal '.', url.relative_path_to('http://example.com')
      end

      it "returns '.' with 'http://example.com/'" do
        assert_equal '.', url.relative_path_to('http://example.com/')
      end

      it "returns 'file' with 'http://example.com/file?query#frag'" do
        assert_equal 'file', url.relative_path_to('http://example.com/file?query#frag')
      end

      it "returns 'some:file' with 'http://example.com/some:file'" do
        assert_equal 'some:file', url.relative_path_to('http://example.com/some:file')
      end

      it "returns 'some:file' with 'http://example.com/some:file?query#frag'" do
        assert_equal 'some:file', url.relative_path_to('http://example.com/some:file?query#frag')
      end

      it "returns nil with '/file'" do
        assert_nil url.relative_path_to('/file')
      end

      it "returns nil with 'file'" do
        assert_nil url.relative_path_to('file')
      end

      it "returns nil with 'https://example.com'" do
        assert_nil url.relative_path_to('https://example.com')
      end

      it "returns nil with 'http://not.example.com/file'" do
        assert_nil url.relative_path_to('http://not.example.com/file')
      end
    end

    context "when the URL is 'http://example.com/'" do
      let :url do
        URL.parse 'http://example.com/'
      end

      it "returns '.' with 'http://example.com'" do
        assert_equal '.', url.relative_path_to('http://example.com')
      end
    end
  end

  describe "#relative_path_from" do
    let :url do
      URL.new
    end

    it "returns the given url's #relative_path_to to self" do
      any_instance_of URL do |instance|
        stub(instance).relative_path_to(url) { 'path' }
      end
      assert_equal 'path', url.relative_path_from('url')
    end
  end
end
