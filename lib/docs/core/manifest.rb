require 'yajl/json_gem'

module Docs
  class Manifest
    FILENAME = 'docs.json'

    def initialize(store, docs)
      @store = store
      @docs = docs
    end

    def store
      @store.write FILENAME, to_json
    end

    def as_json
      @docs.each_with_object [] do |doc, result|
        next unless @store.exist?(doc.meta_path)
        result << doc.as_json_extra(@store)
      end
    end

    def to_json
      JSON.pretty_generate(as_json)
    end
  end
end
