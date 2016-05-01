require 'test_helper'
require 'docs'

class EntriesFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::EntriesFilter

  before do
    stub(filter).root_page? { false }
  end

  describe ":entries" do
    before do
      stub(filter).name { 'name' }
      stub(filter).path { 'path' }
      stub(filter).type { 'type' }
    end

    let :entries do
      filter_result[:entries]
    end

    it "is an array" do
      assert_instance_of Array, entries
    end

    it "includes the default entry when #include_default_entry? is true" do
      stub(filter).include_default_entry? { true }
      refute_empty entries
    end

    it "doesn't include the default entry when #include_default_entry? is false" do
      stub(filter).include_default_entry? { false }
      assert_empty entries
    end

    it "always includes the default entry when #root_page? is true" do
      stub(filter).include_default_entry? { false }
      stub(filter).root_page? { true }
      refute_empty entries
    end

    describe "the default entry" do
      it "has the #name, #path and #type" do
        assert_equal 'name', entries.first.name
        assert_equal 'path', entries.first.path
        assert_equal 'type', entries.first.type
      end
    end

    it "includes the #additional_entries" do
      stub(filter).additional_entries { [['name']] }
      assert_equal 2, entries.length
    end

    describe "an additional entry" do
      it "has the given name" do
        stub(filter).additional_entries { [['test']] }
        assert_equal 'test', entries.last.name
      end

      it "has a default path equal to #path" do
        stub(filter).additional_entries { [['test']] }
        assert_equal 'path', entries.last.path
      end

      it "has a path with the given fragment" do
        stub(filter).additional_entries { [['test', 'frag']] }
        assert_equal 'path#frag', entries.last.path
      end

      it "has a path with the given path" do
        stub(filter).additional_entries { [['test', 'custom_path#frag']] }
        assert_equal 'custom_path#frag', entries.last.path
      end

      it "has the given type" do
        stub(filter).additional_entries { [['test', nil, 'test']] }
        assert_equal 'test', entries.last.type
      end

      it "has a default type equal to #type" do
        stub(filter).additional_entries { [['test']] }
        assert_equal 'type', entries.last.type
      end

      it "has a type equal to #type when the given type is nil" do
        stub(filter).additional_entries { [['test', nil, nil]] }
        assert_equal 'type', entries.last.type
      end
    end
  end

  describe "#name" do
    context "when #root_page? is true" do
      it "returns nil" do
        stub(filter).root_page? { true }
        assert_nil filter.name
      end
    end

    context "when #root_page? is false" do
      before do
        stub(filter).root_page? { false }
        stub(filter).get_name { 'name' }
      end

      it "returns #get_name" do
        assert_equal 'name', filter.name
      end

      it "is memoized" do
        assert_same filter.name, filter.name
      end
    end
  end

  describe "#get_name" do
    it "returns 'file-name' when #slug is 'file-name'" do
      stub(filter).slug { 'file-name' }
      assert_equal 'file-name', filter.get_name
    end

    it "returns 'file name' when #slug is '_file__name_'" do
      stub(filter).slug { '_file__name_' }
      assert_equal 'file name', filter.get_name
    end

    it "returns 'file.name' when #slug is 'file/name'" do
      stub(filter).slug { 'file/name' }
      assert_equal 'file.name', filter.get_name
    end
  end

  describe "#type" do
    context "when #root_page? is true" do
      it "returns nil" do
        stub(filter).root_page? { true }
        assert_nil filter.type
      end
    end

    context "when #root_page? is false" do
      before do
        stub(filter).root_page? { false }
        stub(filter).get_type { 'type' }
      end

      it "returns #get_type" do
        assert_equal 'type', filter.type
      end

      it "is memoized" do
        assert_same filter.type, filter.type
      end
    end
  end
end
