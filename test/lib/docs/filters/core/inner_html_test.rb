require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class InnerHtmlFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::InnerHtmlFilter

  it "returns the document as a string" do
    @body = Nokogiri::HTML.fragment('<p>Test</p>')
    assert_equal '<p>Test</p>', filter_output
  end

  it "returns a valid string" do
    invalid_string = "\x92"
    @body = Nokogiri::HTML.parse(invalid_string)
    assert filter_output.valid_encoding?
  end
end
