require 'test_helper'
require 'docs'

class DocsEntryTest < MiniTest::Spec
  Entry = Docs::Entry

  let :entry do
    Entry.new
  end

  describe ".new" do
    it "stores a name" do
      assert_equal 'name', Entry.new('name').name
    end

    it "stores a path" do
      assert_equal 'path', Entry.new(nil, 'path').path
    end

    it "stores a type" do
      assert_equal 'type', Entry.new(nil, nil, 'type').type
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
      assert_equal Entry.new, Entry.new
    end

    it "returns false when the other has a different name" do
      entry.name = 'name'
      refute_equal Entry.new, entry
    end

    it "returns false when the other has a different path" do
      entry.path = 'path'
      refute_equal Entry.new, entry
    end

    it "returns false when the other has a different type" do
      entry.type = 'type'
      refute_equal Entry.new, entry
    end
  end

  describe "#<=>" do
    it "returns 1 when the other's name is less" do
      assert_equal 1, Entry.new('b') <=> Entry.new('a')
    end

    it "returns -1 when the other's name is greater" do
      assert_equal -1, Entry.new('a') <=> Entry.new('b')
    end

    it "returns 0 when the other's name is equal" do
      assert_equal 0, Entry.new('a') <=> Entry.new('a')
    end

    it "is case-insensitive" do
      assert_equal 0, Entry.new('a') <=> Entry.new('A')
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
