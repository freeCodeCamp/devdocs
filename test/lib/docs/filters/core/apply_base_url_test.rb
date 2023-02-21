require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class ApplyBaseUrlFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::ApplyBaseUrlFilter
  self.filter_type = 'html'

  context "when there is no <base>" do
    it "does nothing" do
      @body = make_body nil, link_to('test')
      assert_equal link_to('test'), filter_output.at_css('body').inner_html
    end
  end

  context "when <base> is '/base/'" do
    it "rewrites relative urls" do
      @body = make_body '/base/', link_to('path#frag')
      assert_equal link_to('/base/path#frag'), filter_output.at_css('body').inner_html
    end

    it "rewrites relative image urls" do
      @body = make_body '/base/', '<img src="../img.png">'
      assert_equal '<img src="/base/../img.png">', filter_output.at_css('body').inner_html
    end

    it "rewrites relative iframe urls" do
      @body = make_body '/base/', '<iframe src="./test"></iframe>'
      assert_equal '<iframe src="/base/./test"></iframe>', filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite absolute urls" do
      @body = make_body '/base/', link_to('http://example.com')
      assert_equal link_to('http://example.com'), filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite protocol-less urls" do
      @body = make_body '/base/', link_to('//example.com')
      assert_equal link_to('//example.com'), filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite root-relative urls" do
      @body = make_body '/base/', link_to('/path')
      assert_equal link_to('/path'), filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite fragment-only urls" do
      @body = make_body '/base/', link_to('#test')
      assert_equal link_to('#test'), filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite email urls" do
      @body = make_body '/base/', link_to('mailto:test@example.com')
      assert_equal link_to('mailto:test@example.com'), filter_output.at_css('body').inner_html
    end

    it "doesn't rewrite data urls" do
      @body = make_body '/base/', '<img src="data:image/gif;base64,aaaa">'
      assert_equal '<img src="data:image/gif;base64,aaaa">', filter_output.at_css('body').inner_html
    end
  end

  private

  def make_body(base, body)
    base = %(<base href="#{base}">) if base
    "<html><meta charset=utf-8><title></title>#{base}#{body}</html>"
  end
end
