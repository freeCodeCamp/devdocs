module Docs
  class Entry
    attr_accessor :name, :type, :path

    def initialize(name = nil, path = nil, type = nil)
      self.name = name
      self.path = path
      self.type = type
    end

    def ==(other)
      other.name == name && other.path == path && other.type == type
    end

    def <=>(other)
      name.to_s.casecmp(other.name.to_s)
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
