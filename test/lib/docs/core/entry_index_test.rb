require 'test_helper'
require 'docs'

class DocsEntryIndexTest < MiniTest::Spec
  let :entry do
    Docs::Entry.new 'name', 'type', 'path'
  end

  let :index do
    Docs::EntryIndex.new
  end

  describe "#entries" do
    it "returns an Array" do
      assert_instance_of Array, index.entries
    end
  end

  describe "#types" do
    it "returns a hash" do
      assert_instance_of Hash, index.types
    end
  end

  describe "#add" do
    it "stores an entry" do
      index.add(entry)
      assert_includes index.entries, entry
    end

    it "stores an array of entries" do
      entries = [entry, entry]
      index.add(entries)
      assert_equal entries, index.entries
    end

    it "duplicates the entry" do
      index.add(entry)
      refute_same entry, index.entries.first
    end

    it "doesn't store the root entry" do
      mock(entry).root? { true }
      index.add(entry)
      assert_empty index.entries
      assert_empty index.types
    end

    it "creates and indexes the type" do
      entry.type = 'one'; index.add(entry)
      entry.type = 'two'; 2.times { index.add(entry) }
      assert_equal ['one', 'two'], index.types.keys
      assert_instance_of Docs::Type, index.types['one']
    end

    it "doesn't index the nil type" do
      entry.type = nil; index.add(entry)
      assert_empty index.types
    end

    it "increments the type's count" do
      2.times { index.add(entry) }
      assert_equal 2, index.types[entry.type].count
    end
  end

  describe "#empty? / #blank? / #present?" do
    it "is #empty? and #blank? when no entries have been added" do
      assert index.empty?
      assert index.blank?
      refute index.present?
    end

    it "is #present? when an entry has been added" do
      index.add(entry)
      refute index.empty?
      refute index.blank?
      assert index.present?
    end
  end

  describe "#as_json" do
    it "returns a Hash" do
      assert_instance_of Hash, index.as_json
    end

    describe ":entries" do
      it "is an empty array by default" do
        assert_instance_of Array, index.as_json[:entries]
      end

      it "includes the json representation of the #entries" do
        index.add [entry, entry]
        assert_equal [entry.as_json, entry.as_json], index.as_json[:entries]
      end

      it "is sorted by name, case-insensitive" do
        entry.name = 'B'; index.add(entry)
        entry.name = 'a'; index.add(entry)
        entry.name = 'c'; index.add(entry)
        entry.name = nil; index.add(entry)
        assert_equal [nil, 'a', 'B', 'c'], index.as_json[:entries].map { |e| e[:name] }
      end
    end

    describe ":types" do
      it "is an empty array by default" do
        assert_instance_of Array, index.as_json[:types]
      end

      it "includes the json representation of the #types" do
        type = Docs::Type.new 'one', 1
        entry.type = 'one'; index.add(entry)
        assert_equal type.as_json, index.as_json[:types].first
      end

      it "is sorted by name, case-insensitive" do
        entry.type = 'B'; index.add(entry)
        entry.type = 'a'; index.add(entry)
        entry.type = 'c'; index.add(entry)
        assert_equal ['a', 'B', 'c'], index.as_json[:types].map { |e| e[:name] }
      end
    end
  end

  describe "#to_json" do
    it "returns the JSON string for #as_json" do
      stub(index).as_json { { entries: [1], types: [2] } }
      assert_equal '{"entries":[1],"types":[2]}', index.to_json
    end
  end
end
