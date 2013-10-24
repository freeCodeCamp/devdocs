module Docs
  class FilterStack
    extend Forwardable
    def_delegators :@filters, :length, :inspect

    attr_reader :filters

    def initialize(filters = nil)
      @filters = filters ? filters.dup : []
    end

    def push(*names)
      @filters.push *filter_const(names)
    end

    def insert(index, *names)
      @filters.insert assert_index(index), *filter_const(names)
    end

    alias_method :insert_before, :insert

    def insert_after(index, *names)
      insert assert_index(index) + 1, *names
    end

    def replace(index, name)
      @filters[assert_index(index)] = filter_const(name)
    end

    def ==(other)
      other.is_a?(self.class) && filters == other.filters
    end

    def to_a
      @filters.dup
    end

    def inheritable_copy
      self.class.new @filters
    end

    private

    def filter_const(name)
      if name.is_a? Array
        name.map &method(:filter_const)
      else
        Docs.const_get "#{name}_filter".camelize
      end
    end

    def assert_index(index)
      i = index.is_a?(Integer) ? index : @filters.index(filter_const(index))
      raise "No such filter to insert: #{index}" unless i
      i
    end
  end
end
