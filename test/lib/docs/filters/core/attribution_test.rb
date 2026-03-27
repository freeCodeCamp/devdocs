require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class AttributionFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::AttributionFilter
  self.filter_type = 'html'

  before do
    @body = "<div class=\"doc\">Hello!</div>"
  end

  context "when attribution is a string" do
    before do
      context[:attribution] = "<span id=\"mtwain\">Copyright 2033 Mark Twain</span>"
      context[:base_url] = "q"
    end

    it "adds it to the document" do
      assert_equal filter_output.at_css('#mtwain').inner_html, "Copyright 2033 Mark Twain"
      refute_nil filter_output.at_css('p._attribution-p'), "Attribution node should exist"
      refute_nil filter_output.at_css('.doc'), "Existing doc should still be present"
      refute_nil filter_output.at_css('a._attribution-link'), "Attribution link should exist"
    end
  end

  context "when attribution is a Proc" do
      before do
      context[:attribution] = ->(filter) {
        "<span id=\"mtwain\">Copyright 2034 Mark Twain</span>"
      }
      context[:base_url] = "q"
    end

    it "adds its output to the document" do
      assert_equal filter_output.at_css('#mtwain').inner_html, "Copyright 2034 Mark Twain"
    end
  end
end
