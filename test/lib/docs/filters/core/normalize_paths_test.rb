require 'test_helper'
require 'docs'

class NormalizePathsFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::NormalizePathsFilter

  describe "#path" do
    it "returns 'index' when the page is the root page" do
      mock(filter).root_page? { true }
      assert_equal 'index', filter.path
    end

    it "returns 'test/index' when #subpath is 'test/'" do
      stub(filter).subpath { 'test/' }
      assert_equal 'test/index', filter.path
    end

    it "returns 'test' when #subpath is '/test'" do
      stub(filter).subpath { '/test' }
      assert_equal 'test', filter.path
    end
  end

  describe "#store_path" do
    it "returns 'index.html' when #path is 'index'" do
      stub(filter).path { 'index' }
      assert_equal 'index.html', filter.store_path
    end

    it "returns 'index.html' when #path is 'index.html'" do
      stub(filter).path { 'index.html' }
      assert_equal 'index.html', filter.store_path
    end

    it "returns 'page.ext.html' when #path is 'page.ext'" do
      stub(filter).path { 'page.ext' }
      assert_equal 'page.ext.html', filter.store_path
    end
  end

  describe "#normalize_path" do
    it "returns 'index' with '.'" do
      assert_equal 'index', filter.normalize_path('.')
    end

    it "returns 'test' with 'TEST'" do
      assert_equal 'test', filter.normalize_path('TEST')
    end

    it "returns 'test/index' with 'test/'" do
      assert_equal 'test/index', filter.normalize_path('test/')
    end

    it "returns 'test' with 'test.html'" do
      assert_equal 'test', filter.normalize_path('test.html')
    end
  end

  before do
    stub(filter).subpath { '' }
  end

  it "rewrites relative urls" do
    @body = link_to 'TEST/'
    assert_equal link_to('test/index'), filter_output_string
  end

  it "doesn't rewrite absolute urls" do
    @body = link_to 'http://example.com'
    assert_equal @body, filter_output_string
  end

  it "retains query strings" do
    @body = link_to 'TEST/?query'
    assert_equal link_to('test/index?query'), filter_output_string
  end

  it "retains fragments" do
    @body = link_to 'TEST/#frag'
    assert_equal link_to('test/index#frag'), filter_output_string
  end

  it "doesn't rewrite mailto urls" do
    @body = link_to 'mailto:'
    assert_equal @body, filter_output_string
  end

  it "doesn't rewrite ftp urls" do
    @body = link_to 'ftp://example.com'
    assert_equal @body, filter_output_string
  end

  it "doesn't rewrite invalid urls" do
    @body = link_to '.%'
    assert_equal @body, filter_output_string
  end
end
