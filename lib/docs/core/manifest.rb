require 'yajl/json_gem'

module Docs
  class Manifest
    FILENAME = 'docs.json'

    def initialize(store, docs, aliases)
      @store = store
      @docs = docs
      @aliases = aliases
    end

    def store
      @store.write FILENAME, to_json
    end

    def as_json
      @docs.each_with_object [] do |doc, result|
        next unless @store.exist?(doc.meta_path)
        json = JSON.parse(@store.read(doc.meta_path))
        if doc.options[:attribution].is_a?(String)
          json[:attribution] = doc.options[:attribution].strip
        end
        json[:alias] = @aliases[doc.slug]
        result << json
      end
    end

    def to_json
      JSON.pretty_generate(as_json)
    end
  end
end
