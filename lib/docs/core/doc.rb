module Docs
  class Doc
    INDEX_FILENAME = 'index.json'

    class << self
      attr_accessor :name, :slug, :type, :version, :abstract

      def inherited(subclass)
        subclass.type = type
      end

      def name
        @name || super.try(:demodulize)
      end

      def slug
        @slug || name.try(:downcase)
      end

      def path
        slug
      end

      def index_path
        File.join path, INDEX_FILENAME
      end

      def as_json
        { name: name,
          slug: slug,
          type: type,
          version: version,
          index_path: index_path }
      end

      def index_page(id)
        if (page = new.build_page(id)) && page[:entries].present?
          yield page[:store_path], page[:output]
          index = EntryIndex.new
          index.add page[:entries]
          index
        end
      end

      def index_pages
        index = EntryIndex.new
        new.build_pages do |page|
          next if page[:entries].blank?
          yield page[:store_path], page[:output]
          index.add page[:entries]
        end
        index.empty? ? nil : index
      end

      def store_page(store, id)
        store.open path do
          index = index_page(id, &store.method(:write))
          !!index
        end
      end

      def store_pages(store)
        store.replace path do
          index = index_pages(&store.method(:write))
          store.write INDEX_FILENAME, index.to_json if index
          !!index
        end
      end
    end

    def initialize
      raise NotImplementedError, "#{self.class} is an abstract class and cannot be instantiated." if self.class.abstract
    end

    def build_page(id, &block)
      raise NotImplementedError
    end

    def build_pages(&block)
      raise NotImplementedError
    end
  end
end
