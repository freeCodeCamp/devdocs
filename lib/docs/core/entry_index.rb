require 'yajl/json_gem'

module Docs
  class EntryIndex
    attr_reader :entries, :types

    def initialize
      @entries = []
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
      @entries << entry.dup
      @types[entry.type].count += 1 if entry.type
    end

    def entries_as_json
      @entries.sort!.map { |entry| entry.as_json }
    end

    def types_as_json
      @types.values.sort!.map { |type| type.as_json }
    end
  end
end
