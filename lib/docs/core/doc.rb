module Docs
  class Doc
    INDEX_FILENAME = 'index.json'
    DB_FILENAME = 'db.json'
    META_FILENAME = 'meta.json'

    class << self
      include Instrumentable

      attr_accessor :name, :slug, :type, :release, :abstract, :links

      def inherited(subclass)
        subclass.type = type
      end

      def version(version = nil, &block)
        return @version unless block_given?

        klass = Class.new(self)
        klass.name = name
        klass.slug = slug
        klass.version = version
        klass.release = release
        klass.links = links
        klass.class_exec(&block)
        @versions ||= []
        @versions << klass
        klass
      end

      def version=(value)
        @version = value.to_s
      end

      def versions
        @versions.presence || [self]
      end

      def version?
        version.present?
      end

      def versioned?
        @versions.presence
      end

      def name
        @name || super.demodulize
      end

      def slug
        slug = @slug || default_slug || raise('slug is required')
        version? ? "#{slug}~#{version_slug}" : slug
      end

      def version_slug
        return if version.blank?
        slug = version.downcase
        slug.gsub! '+', 'p'
        slug.gsub! '#', 's'
        slug.gsub! %r{[^a-z0-9\_\.]}, '_'
        slug
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

      def meta_path
        File.join path, META_FILENAME
      end

      def as_json
        json = { name: name, slug: slug, type: type }
        json[:links] = links if links.present?
        json[:version] = version if version.present? || defined?(@version)
        json[:release] = release if release.present?
        json
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
            store_meta(store)
            true
          else
            false
          end
        end
      end

      private

      def default_slug
        return if name =~ /[^A-Za-z0-9_]/
        name.downcase
      end

      def store_page?(page)
        page[:entries].present?
      end

      def store_index(store, filename, index)
        old_json = store.read(filename) || '{}'
        new_json = index.to_json
        instrument "#{filename.remove('.json')}.doc", before: old_json, after: new_json
        store.write(filename, new_json)
      end

      def store_meta(store)
        json = as_json
        json[:mtime] = Time.now.to_i
        json[:db_size] = store.size(DB_FILENAME)
        store.write(META_FILENAME, json.to_json)
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
