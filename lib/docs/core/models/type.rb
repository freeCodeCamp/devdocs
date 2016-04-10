module Docs
  Type = Struct.new :name, :count do
    attr_accessor :slug

    def initialize(*args)
      super
      self.count ||= 0
    end

    STARTS_WITH_INTEGER = /\A\d/

    def <=>(other)
      if name && other && name =~ STARTS_WITH_INTEGER && other.name =~ STARTS_WITH_INTEGER
        name.to_i <=> other.name.to_i
      else
        name.to_s.casecmp(other.name.to_s)
      end
    end

    def slug
      name.parameterize
    end

    def as_json
      to_h.merge! slug: slug
    end
  end
end
