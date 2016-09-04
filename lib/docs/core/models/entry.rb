# frozen_string_literal: true

module Docs
  class Entry
    class Invalid < StandardError; end

    attr_accessor :name, :type, :path

    def initialize(name = nil, path = nil, type = nil)
      self.name = name
      self.path = path
      self.type = type

      unless root?
        raise Invalid, 'missing name' if !name || name.empty?
        raise Invalid, 'missing path' if !path || path.empty?
        raise Invalid, 'missing type' if !type || type.empty?
      end
    end

    def ==(other)
      other.name == name && other.path == path && other.type == type
    end

    def name=(value)
      @name = value.try :strip
    end

    def type=(value)
      @type = value.try :strip
    end

    def root?
      path == 'index'
    end

    def as_json
      { name: name, path: path, type: type }
    end
  end
end
