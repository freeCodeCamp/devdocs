require 'test_helper'
require 'docs'

class CleanHtmlFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::CleanHtmlFilter

  it "removes <script> and <style>" do
    @body = '<div><script></script><style></style></div>'
    assert_equal '<div></div>', filter_output_string
  end

  it "removes comments" do
    @body = '<!-- test --><div>Test<!-- test --></div>'
    assert_equal '<div>Test</div>', filter_output_string
  end

  it "removes extraneous whitespace" do
    @body = "<p> \nTest <b></b> \n</p> \n<div>\r</div>\n\n "
    assert_equal '<p> Test <b></b> </p> <div> </div> ', filter_output_string
  end

  it "doesn't remove whitespace from <pre> and <code> nodes" do
    @body = "<pre> \nTest\r </pre><code> \nTest </code>"
    assert_equal @body, filter_output_string
  end

  it "doesn't remove invalid strings" do
    @body = Nokogiri::HTML.parse "\x92"
    assert_equal @body.to_s, filter_output_string
  end
end
