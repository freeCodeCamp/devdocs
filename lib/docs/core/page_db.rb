require 'yajl/json_gem'

module Docs
  class PageDb
    attr_reader :pages

    delegate :empty?, :blank?, to: :pages

    def initialize
      @pages = {}
    end

    def add(path, content)
      @pages[path] = content
    end

    def as_json
      @pages
    end

    def to_json
      JSON.generate(as_json)
    end
  end
end
