require 'docs/mdn_content/data'
require 'docs/mdn_content/generator'
require 'docs/mdn_content/macros'
require 'docs/mdn_content/markdown'
require 'docs/mdn_content/pages'

module Docs
  # The MDN documentations built from the markdown of the content repository
  # (https://github.com/mdn/content) rather than from the pages MDN serves,
  # which are those same documents with their sidebars, compatibility tables
  # and specifications rendered into them. Everything the scrapers need is one
  # download away, so a documentation is built in the time the crawler used to
  # spend waiting on developer.mozilla.org.
  #
  # The documentations that haven't moved over yet inherit Mdn, which
  # crawls developer.mozilla.org.
  class MdnGit < FileScraper
    self.abstract = true
    self.type = 'mdn'
    self.links = {
      home: 'https://developer.mozilla.org',
      code: 'https://github.com/mdn/content'
    }

    class << self
      # The directory of the content repository holding the pages, relative to
      # its files/en-us, and the slug that directory stands for.
      attr_accessor :content_path, :slug_prefix

      # The npm packages MDN builds its compatibility tables, its list of
      # specifications and its Baseline indicators out of. A documentation can
      # add the ones it needs; see Css.
      attr_accessor :data_packages

      def inherited(subclass)
        super
        subclass.content_path = content_path
        subclass.slug_prefix = slug_prefix
        subclass.data_packages = data_packages.dup
      end
    end

    self.data_packages = {
      'browser-compat-data' => '@mdn/browser-compat-data',
      'web-features' => 'web-features',
      'web-specs' => 'web-specs'
    }

    html_filters.insert_before 'normalize_urls', 'mdn_git/macros', 'mdn_git/clean_html'

    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2025 MDN contributors.<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v2.5 or later.
    HTML

    def get_latest_version(opts)
      get_latest_github_commit_date('mdn', 'content', opts)
    end

    # Every page is known upfront, so there's nothing to crawl: the scraper is
    # handed the whole documentation and never has to follow a link to find a
    # page.
    def initial_paths
      @initial_paths ||= pages.map(&:slug).reject { |slug| slug.empty? || skip?(slug) }.sort
    end

    def build_pages(&block)
      # Reading the pages and the data files here rather than in the forked
      # workers means doing it once instead of once per job.
      initial_paths
      options
      super
    end

    private

    def pages
      @pages ||= begin
        assert_source_directory_exists
        MdnContent::Pages.new source_directory, self.class.slug_prefix
      end
    end

    def generator
      @generator ||= MdnContent::Generator.new(MdnContent::Data.new(data_directory))
    end

    def data_directory
      File.join source_directory, '_data'
    end

    def skip?(slug)
      slug = "/#{slug}"
      Array(self.class.options[:skip]).any? { |value| slug.casecmp(value) == 0 } ||
        Array(self.class.options[:skip_patterns]).any? { |pattern| slug.match?(pattern) }
    end

    def page_for(url)
      slug = url.to_s.remove(self.class.base_url).delete_prefix('/')
      pages[slug] || raise("no page for #{url}")
    end

    def url_to_path(url)
      page_for(url).path
    end

    def parse(response)
      page = page_for response.url
      html = generator.header(page) + MdnContent::Markdown.render(pages.body(page))
      [Parser.new(html).html, page.title]
    end

    def additional_options
      { pages: pages, generator: generator }
    end

    def pipeline_context(response)
      super.merge page: page_for(response.url)
    end

    def download_source
      download_and_extract 'https://github.com/mdn/content/archive/refs/heads/main.tar.gz',
                           "content-main/files/en-us/#{self.class.content_path}"

      self.class.data_packages.each do |directory, package|
        download_and_extract npm_tarball(package), 'package', destination: File.join(data_directory, directory)
      end

      instrument 'info.doc', msg: 'Reducing the data files to what the documentation needs...'
      MdnContent::Data.prepare data_directory, compat_namespaces
    end

    # The sections of browser-compat-data the pages query, e.g. "javascript"
    # and "api". Everything else is dropped, which is most of it.
    def compat_namespaces
      pages.flat_map { |page| page.browser_compat.map { |query| query.split('.').first } }.uniq
    end

    def npm_tarball(package)
      response = Request.run "https://registry.npmjs.org/#{package}/latest"
      raise SetupError, %(Failed to look up "#{package}" on npm) unless response.success?
      JSON.parse(response.body).dig('dist', 'tarball')
    end
  end
end
