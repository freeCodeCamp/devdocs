require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class DocsTypeTest < MiniTest::Spec
  Type = Docs::Type

  describe ".new" do
    it "stores a name" do
      assert_equal 'name', Type.new('name').name
    end

    it "stores a count" do
      assert_equal 10, Type.new(nil, 10).count
    end

    it "defaults the count to 0" do
      assert_equal 0, Type.new.count
    end
  end

  describe "#slug" do
    it "parameterizes the #name" do
      name = 'a.b c\/%?#'
      assert_equal 'a-b-c', Type.new(name).slug
    end
  end

  describe "#as_json" do
    it "returns a hash with the name, count and slug" do
      as_json = Type.new('name', 10).as_json
      assert_instance_of Hash, as_json
      assert_equal [:name, :count, :slug], as_json.keys
      assert_equal ['name', 10, 'name'], as_json.values
    end
  end
end
