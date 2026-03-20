require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class CleanLocalUrlsFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::CleanLocalUrlsFilter

  it "removes images/iframes referencing localhost" do
    context[:base_url] = 'http://localhost'
    @body = '<img src="http://localhost/img.png"><iframe src="http://localhost/frame"></iframe>'
    assert_empty filter_output.css('img, iframe')
  end

  it "turns links referencing localhost into plain text" do
    context[:base_url] = 'http://localhost'
    @body = '<a href="http://localhost/page">Link</a>'
    node = filter_output.at_css('span')
    assert node, 'expected a <span> node'
    refute node['href']
    assert_equal 'Link', node.text
  end
end
