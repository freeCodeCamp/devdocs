require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class ParseCfEmailFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::ParseCfEmailFilter

  before do
    context[:url] = 'http://example.com/dir/file'
  end

  it 'rewrites parses CloudFlare mail addresses' do
    href = 'b3dddad0d6d2ddd7c0dadec3dfd6f3d6cbd2dec3dfd69dd0dcde'
    @body = %(<a class="__cf_email__" data-cfemail="#{href}">Link</a>)
    assert_equal 'niceandsimple@example.com', filter_output_string
  end
end
