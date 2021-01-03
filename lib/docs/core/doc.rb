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
      rescue Docs::SetupError => error
        puts "ERROR: #{error.message}"
        false
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
      rescue Docs::SetupError => error
        puts "ERROR: #{error.message}"
        false
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

    def get_scraper_version(opts)
      if self.class.method_defined?(:options) and !options[:release].nil?
        options[:release]
      else
        # If options[:release] does not exist, we return the Epoch timestamp of when the doc was last modified in DevDocs production
        json = fetch_json('https://devdocs.io/docs.json', opts)
        items = json.select {|item| item['name'] == self.class.name}
        items = items.map {|item| item['mtime']}
        items.max
      end
    end

    # Should return the latest version of this documentation
    # If options[:release] is defined, it should be in the same format
    # If options[:release] is not defined, it should return the Epoch timestamp of when the documentation was last updated
    # If the docs will never change, simply return '1.0.0'
    def get_latest_version(opts)
      raise NotImplementedError
    end

    # Returns whether or not this scraper is outdated ("Outdated major version", "Outdated minor version" or 'Up-to-date').
    #
    # The default implementation assumes the documentation uses a semver(-like) approach when it comes to versions.
    # Patch updates are ignored because there are usually little to no documentation changes in bug-fix-only releases.
    #
    # Scrapers of documentations that do not use this versioning approach should override this method.
    #
    # Examples of the default implementation:
    # 1 -> 2 = outdated
    # 1.1 -> 1.2 = outdated
    # 1.1.1 -> 1.1.2 = not outdated
    def outdated_state(scraper_version, latest_version)
      scraper_parts = scraper_version.to_s.split(/[-.]/).map(&:to_i)
      latest_parts = latest_version.to_s.split(/[-.]/).map(&:to_i)

      # Only check the first two parts, the third part is for patch updates
      [0, 1].each do |i|
        break if i >= scraper_parts.length or i >= latest_parts.length
        return 'Outdated major version' if i == 0 and latest_parts[i] > scraper_parts[i]
        return 'Outdated minor version' if i == 1 and latest_parts[i] > scraper_parts[i]
        return 'Up-to-date' if latest_parts[i] < scraper_parts[i]
      end

      'Up-to-date'
    end

    private

    #
    # Utility methods for get_latest_version
    #

    def fetch(url, opts)
      headers = {}

      if opts.key?(:github_token) and url.start_with?('https://api.github.com/')
        headers['Authorization'] = "token #{opts[:github_token]}"
      elsif ENV['GITHUB_TOKEN'] and url.start_with?('https://api.github.com/')
        headers['Authorization'] = "token #{ENV['GITHUB_TOKEN']}"
      end

      opts[:logger].debug("Fetching #{url}")
      response = Request.run(url, { connecttimeout: 15, headers: headers })

      if response.success?
        response.body
      else
        reason = response.timed_out? ? "Timed out while connecting to #{url}" : "Couldn't fetch #{url} (response code #{response.code})"
        opts[:logger].error(reason)
        raise reason
      end
    end

    def fetch_doc(url, opts)
      body = fetch(url, opts)
      Nokogiri::HTML.parse(body, nil, 'UTF-8')
    end

    def fetch_json(url, opts)
      JSON.parse fetch(url, opts)
    end

    def get_npm_version(package, opts)
      json = fetch_json("https://registry.npmjs.com/#{package}", opts)
      json['dist-tags']['latest']
    end

    def get_latest_github_release(owner, repo, opts)
      release = fetch_json("https://api.github.com/repos/#{owner}/#{repo}/releases/latest", opts)
      tag_name = release['tag_name']
      tag_name.start_with?('v') ? tag_name[1..-1] : tag_name
    end

    def get_github_tags(owner, repo, opts)
      fetch_json("https://api.github.com/repos/#{owner}/#{repo}/tags", opts)
    end

    def get_github_file_contents(owner, repo, path, opts)
      json = fetch_json("https://api.github.com/repos/#{owner}/#{repo}/contents/#{path}", opts)
      Base64.decode64(json['content'])
    end

    def get_latest_github_commit_date(owner, repo, opts)
      commits = fetch_json("https://api.github.com/repos/#{owner}/#{repo}/commits", opts)
      timestamp = commits[0]['commit']['author']['date']
      Date.iso8601(timestamp).to_time.to_i
    end

    def get_gitlab_tags(hostname, group, project, opts)
      fetch_json("https://#{hostname}/api/v4/projects/#{group}%2F#{project}/repository/tags", opts)
    end
  end
end
