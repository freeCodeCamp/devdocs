require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Filter

  before do
    context[:base_url] = 'http://example.com/path'
    context[:url] = 'http://example.com/path/file'
  end

  describe "#subpath" do
    it "returns the #subpath_to the #current_url" do
      stub(filter).subpath_to(filter.current_url) { 'subpath' }
      assert_equal 'subpath', filter.subpath
    end
  end

  describe "#subpath_to" do
    it "returns the subpath from the #base_url to the url, ignoring case" do
      stub(filter.base_url).subpath_to('url', ignore_case: true) { 'subpath' }
      assert_equal 'subpath', filter.subpath_to('url')
    end
  end

  describe "#slug" do
    def slug(subpath)
      stub(filter).subpath { subpath }
      filter.slug
    end

    it "returns '' when #subpath is blank" do
      assert_equal '', slug('')
    end

    it "returns '' when #subpath is '/'" do
      assert_equal '', slug('/')
    end

    it "returns 'path' when #subpath is '/path'" do
      assert_equal 'path', slug('/path')
    end

    it "returns 'path' when #subpath is '/path.html'" do
      assert_equal 'path', slug('/path.html')
    end

    it "returns 'if..else' when #subpath is '/if..else'" do
      assert_equal 'if..else', slug('/if..else')
    end

    it "returns 'dir/path' when #subpath is '/dir/path'" do
      assert_equal 'dir/path', slug('/dir/path')
    end
  end

  describe "#root_page?" do
    it "returns true when #subpath is blank" do
      stub(filter).subpath { '' }
      assert filter.root_page?
    end

    it "returns true when #subpath is '/'" do
      stub(filter).subpath { '/' }
      assert filter.root_page?
    end

    it "returns true when #subpath is the root path" do
      context[:root_path] = '/path'
      stub(filter).subpath { '/path' }
      assert filter.root_page?
    end

    it "returns false when #subpath isn't the root path" do
      stub(filter).subpath { '/path' }
      refute filter.root_page?
    end
  end

  describe "#initial_page?" do
    before do
      context[:initial_paths] = ['initial']
      stub(filter).root_page? { false }
    end

    it "returns true when #root_page? is true" do
      stub(filter).root_page? { true }
      assert filter.initial_page?
    end

    it "returns true when #subpath is included in :initial_paths" do
      stub(filter).subpath { 'initial' }
      assert filter.initial_page?
    end

    it "returns false otherwise" do
      refute filter.initial_page?
    end
  end

  describe "#fragment_url_string?" do
    it "returns false with ''" do
      refute filter.fragment_url_string?('')
    end

    it "returns true with '#'" do
      assert filter.fragment_url_string?('#')
    end

    it "returns false with '/#'" do
      refute filter.fragment_url_string?('/#')
    end

    it "returns false with 'http://example.com/#'" do
      refute filter.fragment_url_string?('http://example.com/#')
    end
  end

  describe "#relative_url_string?" do
    it "returns true with ''" do
      assert filter.relative_url_string?('')
    end

    it "returns true with 'http'" do
      assert filter.relative_url_string?('http')
    end

    it "returns true with '/file'" do
      assert filter.relative_url_string?('/file')
    end

    it "returns true with '?file'" do
      assert filter.relative_url_string?('?file')
    end

    it "returns false with '#file'" do
      refute filter.relative_url_string?('#file')
    end

    it "returns false with 'http://example.com'" do
      refute filter.relative_url_string?('http://example.com')
    end

    it "returns false with 'ftp://example.com'" do
      refute filter.relative_url_string?('ftp://example.com')
    end

    it "returns false with 'mailto:test@example.com'" do
      refute filter.relative_url_string?('mailto:test@example.com')
    end

    it "returns false with 'data:image/gif;base64,foo'" do
      refute filter.relative_url_string?('data:image/gif;base64,foo')
    end
  end

  describe "#absolute_url_string?" do
    it "returns true with 'http://example.com'" do
      assert filter.absolute_url_string?('http://example.com')
    end

    it "returns true with 'ftp://example.com'" do
      assert filter.absolute_url_string?('ftp://example.com')
    end

    it "returns true with 'mailto:test@example.com'" do
      assert filter.absolute_url_string?('mailto:test@example.com')
    end

    it "returns false with ''" do
      refute filter.absolute_url_string?('')
    end

    it "returns false with 'http'" do
      refute filter.absolute_url_string?('http')
    end
  end
end
