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
      indexed_docs.map(&:as_json).each do |json|
        json[:mtime] = @store.mtime(json[:index_path]).to_i
      end
    end

    def to_json
      JSON.generate(as_json)
    end

    private

    def indexed_docs
      @docs.select do |doc|
        @store.exist?(doc.index_path) && @store.exist?(doc.db_path)
      end
    end
  end
end
