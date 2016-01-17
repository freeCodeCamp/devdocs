module Docs
  class Doc
    INDEX_FILENAME = 'index.json'
    DB_FILENAME = 'db.json'

    class << self
      include Instrumentable

      attr_accessor :name, :slug, :type, :release, :abstract, :links

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

      def db_path
        File.join path, DB_FILENAME
      end

      def as_json
        { name: name,
          slug: slug,
          type: type,
          release: release,
          links: links }
      end

      def store_page(store, id)
        store.open(path) do
          if page = new.build_page(id) and store_page?(page)
            store.write page[:store_path], page[:output]
            true
          else
            false
          end
        end
      end

      def store_pages(store)
        index = EntryIndex.new
        pages = PageDb.new

        store.replace(path) do
          new.build_pages do |page|
            next unless store_page?(page)
            store.write page[:store_path], page[:output]
            index.add page[:entries]
            pages.add page[:path], page[:output]
          end

          if index.present?
            store_index(store, INDEX_FILENAME, index)
            store_index(store, DB_FILENAME, pages)
            true
          else
            false
          end
        end
      end

      private

      def store_page?(page)
        page[:entries].present?
      end

      def store_index(store, filename, index)
        old_json = store.read(filename) || '{}'
        new_json = index.to_json
        instrument "#{filename.remove('.json')}.doc", before: old_json, after: new_json
        store.write(filename, new_json)
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
