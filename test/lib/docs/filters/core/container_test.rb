require 'test_helper'
require 'docs'

class ContainerFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::ContainerFilter
  self.filter_type = 'html'

  before do
    @body = '<div>Test</div>'
  end

  context "when context[:container] is a CSS selector" do
    before { context[:container] = '.main' }

    it "returns the element when it exists" do
      @body = '<div><div class="main">Main</div></div><div></div>'
      assert_equal 'Main', filter_output.inner_html
    end

    it "raises an error when the element doesn't exist" do
      assert_raises Docs::ContainerFilter::ContainerNotFound do
        filter.call
      end
    end
  end

  context "when context[:container] is a block" do
    it "calls the block with itself" do
      context[:container] = ->(arg) { @arg = arg; nil }
      filter.call
      assert_equal filter, @arg
    end

    context "and the block returns a CSS selector" do
      before { context[:container] = ->(_) { '.main' } }

      it "returns the element when it exists" do
        @body = '<div><div class="main">Main</div></div>'
        assert_equal 'Main', filter_output.inner_html
      end

      it "raises an error when the element doesn't exist" do
        assert_raises Docs::ContainerFilter::ContainerNotFound do
          filter.call
        end
      end
    end

    context "and the block returns nil" do
      before { context[:container] = ->(_) { nil } }

      it "returns the document" do
        assert_equal @body, filter_output.inner_html
      end
    end
  end

  context "when context[:container] is nil" do
    context "and the document is an HTML fragment" do
      it "returns the document" do
        assert_equal @body, filter_output.inner_html
      end
    end

    context "and the document is an HTML document" do
      it "returns the <body>" do
        @body = '<html><meta charset=utf-8><title></title><div>Test</div></html>'
        assert_equal '<div>Test</div>', filter_output.inner_html
      end
    end
  end
end
