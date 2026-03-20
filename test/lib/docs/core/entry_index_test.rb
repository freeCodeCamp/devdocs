require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsEntryIndexTest < Minitest::Spec
  let :entry do
    Docs::Entry.new 'name', 'path', 'type'
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
      entries = [
        Docs::Entry.new('one', 'path', 'type'),
        Docs::Entry.new('two', 'path', 'type')
      ]

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

    it "doesn't store the same entry twice" do
      2.times { index.add(entry.dup) }
      assert_equal [entry], index.entries
    end

    it "creates and indexes the type" do
      index.add Docs::Entry.new('one', 'path', 'a')
      index.add Docs::Entry.new('two', 'path', 'b')
      index.add Docs::Entry.new('three', 'path', 'b')
      assert_equal ['a', 'b'], index.types.keys
      assert_instance_of Docs::Type, index.types['a']
    end

    it "doesn't index the nil type" do
      entry.type = nil; index.add(entry)
      assert_empty index.types
    end

    it "increments the type's count" do
      index.add Docs::Entry.new('one', 'path', 'type')
      index.add Docs::Entry.new('two', 'path', 'type')
      assert_equal 2, index.types['type'].count
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
        index.add one = Docs::Entry.new('one', 'path', 'type')
        index.add two = Docs::Entry.new('two', 'path', 'type')
        assert_equal [one.as_json, two.as_json], index.as_json[:entries]
      end

      it "is sorted by name, case-insensitive" do
        entry.name = 'B'; index.add(entry)
        entry.name = 'a'; index.add(entry)
        entry.name = 'c'; index.add(entry)
        assert_equal ['a', 'B', 'c'], index.as_json[:entries].map { |e| e[:name] }
      end

      it "sorts numbered names" do
        entry.name = '4.2.2. Test'; index.add(entry)
        entry.name = '4.20. Test'; index.add(entry)
        entry.name = '4.3. Test'; index.add(entry)
        entry.name = '4. Test'; index.add(entry)
        entry.name = '2 Test'; index.add(entry)
        entry.name = 'Test'; index.add(entry)
        assert_equal ['4. Test', '4.2.2. Test', '4.3. Test', '4.20. Test', '2 Test', 'Test'], index.as_json[:entries].map { |e| e[:name] }
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

      it "sorts numbered names" do
        entry.type = '1.8.2. Test'; index.add(entry)
        entry.type = '1.90. Test'; index.add(entry)
        entry.type = '1.9. Test'; index.add(entry)
        entry.type = '9. Test'; index.add(entry)
        entry.type = '1 Test'; index.add(entry)
        entry.type = 'Test'; index.add(entry)
        assert_equal ['1.8.2. Test', '1.9. Test', '1.90. Test', '9. Test', '1 Test', 'Test'], index.as_json[:types].map { |e| e[:name] }
      end
    end
  end

  describe "#sort_fn" do
    def sort(a, b)
      index.send(:sort_fn, a, b)
    end

    context "when neither string starts with a digit 1-9" do
      it "uses case-insensitive string comparison" do
        assert_operator sort('apple', 'banana'), :<, 0
        assert_operator sort('banana', 'apple'), :>, 0
      end

      it "returns 0 for case-insensitive equal strings" do
        assert_equal 0, sort('Apple', 'apple')
      end

      it "treats strings starting with '0' as non-numeric" do
        assert_equal '0apple'.casecmp('banana'), sort('0apple', 'banana')
      end
    end

    context "when at least one string starts with 1-9 but neither contains version dots" do
      it "uses case-insensitive string comparison" do
        # lexicographic: '1' < '2', so '10 Test' < '2 Test'
        assert_operator sort('10 Test', '2 Test'), :<, 0
      end

      it "returns 0 for case-insensitive equal strings" do
        assert_equal 0, sort('2 Test', '2 test')
      end
    end

    context "when one string has version dots and the other does not" do
      it "sorts the dotted string before the undotted one" do
        assert_operator sort('1.2. Test', '2 Test'), :<, 0
      end

      it "sorts the undotted string after the dotted one" do
        assert_operator sort('2 Test', '1.2. Test'), :>, 0
      end

      it "sorts the dotted string before a non-numeric string" do
        assert_operator sort('1.2. Test', 'abc'), :<, 0
      end
    end

    context "when both strings have version dots" do
      it "sorts numerically rather than lexicographically" do
        assert_operator sort('1.9. Test', '1.10. Test'), :<, 0
        assert_operator sort('4.20. Test', '4.3. Test'), :>, 0
      end

      it "pads shorter version depths with zeros before comparing" do
        assert_operator sort('4. Test', '4.2. Test'), :<, 0
        assert_operator sort('4.2. Test', '4. Test'), :>, 0
      end

      it "compares multi-level versions against shorter ones correctly" do
        assert_operator sort('4.2.2. Test', '4.3. Test'), :<, 0
      end

      it "returns 0 for identical version strings" do
        assert_equal 0, sort('1.2. Test', '1.2. Test')
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
