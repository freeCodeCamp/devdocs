require 'yaml'

module Docs
  # Reads the documents of the MDN content repository
  # (https://github.com/mdn/content). Its pages are markdown files with a YAML
  # front matter, sprinkled with the KumaScript macro calls that MDN expands
  # when it builds its site.
  module MdnContent
    # The characters KumaScript strips when it turns the text of a heading into
    # an id. See kumascript/src/api/util.ts in https://github.com/mdn/yari.
    SECTION_ID_DISALLOWED = /["#$%&+,\/:;=?@\[\]^`{|}~')(\\]/

    # Turns the text of a heading into the id MDN gives it, which is what the
    # links to its section are pointing at.
    def self.slugify(text)
      text.strip.gsub(SECTION_ID_DISALLOWED, '').gsub(/\s+/, '_').gsub(/\A_+|_+\z/, '').downcase
    end

    Page = Struct.new(:slug, :path, :front_matter) do
      def title
        front_matter['title']
      end

      def short_title
        front_matter['short-title'] || title
      end

      def page_type
        front_matter['page-type']
      end

      def status
        Array(front_matter['status'])
      end

      def browser_compat
        Array(front_matter['browser-compat'])
      end

      def spec_urls
        Array(front_matter['spec-urls'])
      end

      def deprecated?
        status.include?('deprecated')
      end

      def non_standard?
        status.include?('non-standard')
      end

      def experimental?
        status.include?('experimental')
      end
    end

    # The pages of one section of the content repository, indexed by the slug
    # they hang off, e.g. "Global_Objects/Array/map" for the page whose front
    # matter reads "slug: Web/JavaScript/Reference/Global_Objects/Array/map".
    # The section's own page is indexed under the empty slug.
    class Pages
      include Enumerable

      FRONT_MATTER_DELIMITER = '---'
      INDEX = 'index.md'

      # The part of the slug of every page that the directory stands for.
      attr_reader :prefix

      def initialize(directory, prefix)
        @directory = directory
        @prefix = prefix
      end

      def each(&block)
        index.each_value(&block)
      end

      def [](slug)
        index[slug.to_s.downcase]
      end

      def include?(slug)
        index.key?(slug.to_s.downcase)
      end

      def root
        index['']
      end

      # The pages one level below a slug, in alphabetical order.
      def children(slug)
        below = slug.to_s.downcase
        below += '/' unless below.empty?
        index.select { |key, _| key.start_with?(below) && key.length > below.length && !key[below.length..].include?('/') }.values
      end

      # Reads the markdown of a page, without its front matter.
      def body(page)
        File.read(File.join(@directory, page.path)).sub(/\A#{FRONT_MATTER_DELIMITER}\n.*?\n#{FRONT_MATTER_DELIMITER}\n/m, '')
      end

      private

      def index
        @index ||= build
      end

      def build
        pages = {}

        Dir.glob(File.join(@directory, '**', INDEX)).sort.each do |file|
          front_matter = read_front_matter(file)
          slug = front_matter['slug']
          next unless slug

          path = file.sub(%r{\A#{Regexp.escape(@directory)}/?}, '')
          slug = slug.sub(%r{\A#{Regexp.escape(@prefix)}/?}, '')
          pages[slug.downcase] = Page.new(slug, path, front_matter)
        end

        pages
      end

      # Only the front matter is read here: the pages are parsed in parallel
      # later on, and reading all of them upfront would undo that.
      def read_front_matter(file)
        lines = []
        first = true

        File.foreach(file) do |line|
          if first
            return {} unless line.start_with?(FRONT_MATTER_DELIMITER)
            first = false
          elsif line.start_with?(FRONT_MATTER_DELIMITER)
            break
          else
            lines << line
          end
        end

        # The selectors of the CSS reference start with a colon, which YAML
        # reads as a symbol; they're written back the way they came.
        front_matter = YAML.safe_load(lines.join, permitted_classes: [Symbol]) || {}
        front_matter.transform_values { |value| value.is_a?(Symbol) ? ":#{value}" : value }
      end
    end
  end
end
