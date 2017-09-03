module Docs
  Type = Struct.new :name, :count do
    attr_accessor :slug

    def initialize(*args)
      super
      self.count ||= 0
    end

    def slug
      name.parameterize
    end

    def as_json
      to_h.merge! slug: slug
    end
  end
end
