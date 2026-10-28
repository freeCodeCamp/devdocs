require_relative '../../test_helper'
require_relative '../../../lib/docs'

class DocsCategoriesTest < Minitest::Spec
  it "gives every doc a category in a known ecosystem" do
    pattern = %r{\A(#{Docs::CATEGORIES.join('|')})(/[a-z]+)?\z}
    Docs.all.each do |doc|
      assert_match pattern, doc.category.to_s, "#{doc.name} has no valid category"
      doc.versions.each { |version| assert_equal doc.category, version.category, version.slug }
    end
  end
end
