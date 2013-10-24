require 'test_helper'
require 'docs'

class TitleFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::TitleFilter

  before do
    @body = '<div>Test</div>'
  end

  def output_with_title(title)
    "<h1>#{title}</h1>#{@body}"
  end

  context "when result[:entries] is empty" do
    it "does nothing" do
      assert_equal @body, filter_output.inner_html
    end

    context "and context[:title] is a string" do
      it "prepends a heading containing the title" do
        context[:title] = 'title'
        assert_equal output_with_title('title'), filter_output.inner_html
      end
    end
  end

  context "when result[:entries] is an array" do
    before do
      result[:entries] = [OpenStruct.new(name: 'name'), OpenStruct.new(name: 'name2')]
    end

    it "prepends a heading containing the first entry's name" do
      assert_equal output_with_title('name'), filter_output.inner_html
    end

    context "and context[:title] is a string" do
      it "prepends a heading containing the title" do
        context[:title] = 'title'
        assert_equal output_with_title('title'), filter_output.inner_html
      end
    end

    context "and context[:title] is nil" do
      it "prepends a heading containing the first entry's name" do
        context[:title] = nil
        assert_equal output_with_title('name'), filter_output.inner_html
      end
    end

    context "and context[:title] is false" do
      it "does nothing" do
        context[:title] = false
        assert_equal @body, filter_output.inner_html
      end
    end
  end

  context "when context[:root_title] is a string" do
    before do
      context[:root_title] = 'root'
    end

    context "and context[:title] is a string" do
      before do
        context[:title] = 'title'
      end

      it "prepends a heading containing the root title when #root_page? is true" do
        stub(filter).root_page? { true }
        assert_equal output_with_title('root'), filter_output.inner_html
      end

      it "prepends a heading containing the title when #root_page? is false" do
        stub(filter).root_page? { false }
        assert_equal output_with_title('title'), filter_output.inner_html
      end
    end
  end

  context "when context[:title] is a string" do
    before do
      context[:title] = 'title'
    end

    context "and context[:root_title] is false" do
      it "does nothing when #root_page? is true" do
        context[:root_title] = false
        stub(filter).root_page? { true }
        assert_equal @body, filter_output.inner_html
      end
    end
  end

  context "when context[:title] is a block" do
    it "calls the block with itself" do
      context[:title] = ->(arg) { @arg = arg; nil }
      filter.call
      assert_equal filter, @arg
    end

    it "prepends a heading tag containing the title returned by the block" do
      context[:title] = ->(_) { 'title' }
      assert_equal output_with_title('title'), filter_output.inner_html
    end

    it "does nothing when the block returns nil" do
      context[:title] = ->(_) { nil }
      assert_equal @body, filter_output.inner_html
    end
  end
end
