require 'yajl/json_gem'

module Docs
  class EntryIndex
    attr_reader :entries, :types

    def initialize
      @entries = []
      @index = Set.new
      @types = Hash.new { |hash, key| hash[key] = Type.new key }
    end

    def add(entry)
      if entry.is_a? Array
        entry.each(&method(:add))
      else
        add_entry(entry) unless entry.root?
      end
    end

    def empty?
      @entries.empty?
    end

    alias_method :blank?, :empty?

    def length
      @entries.length
    end

    def as_json
      { entries: entries_as_json, types: types_as_json }
    end

    def to_json
      JSON.generate(as_json)
    end

    private

    def add_entry(entry)
      if @index.add?(entry.as_json.to_s)
        @entries << entry.dup
        @types[entry.type].count += 1 if entry.type
      end
    end

    def entries_as_json
      @entries.sort! { |a, b| sort_fn(a.name, b.name) }.map(&:as_json)
    end

    def types_as_json
      @types.values.sort! { |a, b| sort_fn(a.name, b.name) }.map(&:as_json)
    end

    SPLIT_INTS = /(?<=\d)\.(?=[\s\d])/.freeze

    def sort_fn(a, b)
      if (a.getbyte(0) >= 49 && a.getbyte(0) <= 57) || (b.getbyte(0) >= 49 && b.getbyte(0) <= 57)
        a_split = a.split(SPLIT_INTS)
        b_split = b.split(SPLIT_INTS)

        a_length = a_split.length
        b_length = b_split.length

        return a.casecmp(b) if a_length == 1 && b_length == 1
        return 1 if a_length == 1
        return -1 if b_length == 1

        a_split.each_with_index { |s, i| a_split[i] = s.to_i unless i == a_length - 1 }
        b_split.each_with_index { |s, i| b_split[i] = s.to_i unless i == b_length - 1 }

        if b_length > a_length
          (b_length - a_length).times { a_split.insert(-2, 0) }
        elsif a_length > b_length
          (a_length - b_length).times { b_split.insert(-2, 0) }
        end

        a_split <=> b_split
      else
        a.casecmp(b)
      end
    end
  end
end
