require 'test_helper'
require 'docs'

class DocsEntryTest < MiniTest::Spec
  Entry = Docs::Entry

  let :entry do
    Entry.new('name', 'path', 'type')
  end

  def build_entry(name = 'name', path = 'path', type = 'type')
    Entry.new(name, path, type)
  end

  describe ".new" do
    it "stores #name, #path and #type" do
      entry = Entry.new('name', 'path', 'type')
      assert_equal 'name', entry.name
      assert_equal 'path', entry.path
      assert_equal 'type', entry.type
    end

    it "raises an error when #name, #path or #type is nil or empty" do
      assert_raises(Docs::Entry::Invalid) { Entry.new(nil, 'path', 'type') }
      assert_raises(Docs::Entry::Invalid) { Entry.new('', 'path', 'type') }
      assert_raises(Docs::Entry::Invalid) { Entry.new('name', nil, 'type') }
      assert_raises(Docs::Entry::Invalid) { Entry.new('name', '', 'type') }
      assert_raises(Docs::Entry::Invalid) { Entry.new('name', 'path', nil) }
      assert_raises(Docs::Entry::Invalid) { Entry.new('name', 'path', '') }
    end

    it "don't raise an error when #path is 'index' and #name or #type is nil or empty" do
      Entry.new(nil, 'index', 'type')
      Entry.new('', 'index', 'type')
      Entry.new('name', 'index', nil)
      Entry.new('name', 'index', '')
    end
  end

  describe "#name=" do
    it "removes surrounding whitespace" do
      entry.name = " \n\rname "
      assert_equal 'name', entry.name
    end

    it "accepts nil" do
      entry.name = nil
      assert_nil entry.name
    end
  end

  describe "#type=" do
    it "removes surrounding whitespace" do
      entry.type = " \n\rtype "
      assert_equal 'type', entry.type
    end

    it "accepts nil" do
      entry.type = nil
      assert_nil entry.type
    end
  end

  describe "#==" do
    it "returns true when the other has the same name, path and type" do
      assert_equal build_entry, build_entry
    end

    it "returns false when the other has a different name" do
      entry.name = 'other_name'
      refute_equal build_entry, entry
    end

    it "returns false when the other has a different path" do
      entry.path = 'other_path'
      refute_equal build_entry, entry
    end

    it "returns false when the other has a different type" do
      entry.type = 'other_type'
      refute_equal build_entry, entry
    end
  end

  describe "#root?" do
    it "returns true when #path is 'index'" do
      entry.path = 'index'
      assert entry.root?
    end

    it "returns false when #path is 'path'" do
      entry.path = 'path'
      refute entry.root?
    end
  end

  describe "#as_json" do
    it "returns a hash with the name, path and type" do
      as_json = Entry.new('name', 'path', 'type').as_json
      assert_instance_of Hash, as_json
      assert_equal [:name, :path, :type], as_json.keys
      assert_equal %w(name path type), as_json.values
    end
  end
end
