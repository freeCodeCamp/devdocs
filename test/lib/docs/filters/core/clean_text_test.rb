require 'test_helper'
require 'docs'

class CleanTextFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::CleanTextFilter

  it "removes empty nodes" do
    @body = "<div class=\"test\"><p data><span> \u00A0</span>\n\r<a></a></p></div>"
    assert_empty filter_output
  end

  it "doesn't remove empty <iframe>, <td>, and <th>" do
    @body = "<iframe></iframe><td></td><th></th>"
    assert_equal @body, filter_output
  end

  it "strips leading and trailing whitespace" do
    @body = "\n\r Test \r\n"
    assert_equal 'Test', filter_output
  end
end
