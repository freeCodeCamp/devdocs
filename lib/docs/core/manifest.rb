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
        json[:mtime] = doc_mtime(json)
        json[:db_size] = doc_db_size(json)
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

    def doc_mtime(doc)
      [@store.mtime(doc[:index_path]).to_i, @store.mtime(doc[:db_path]).to_i].max
    end

    def doc_db_size(doc)
      @store.size(doc[:db_path])
    end
  end
end
