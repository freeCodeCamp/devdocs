require 'pathname'

module Docs
  class Valibot < UrlScraper
    self.name = 'Valibot'
    self.slug = 'valibot'
    self.type = 'simple'
    self.release = '1.4.2'
    self.base_url = 'https://valibot.dev/'
    self.links = {
      home: 'https://valibot.dev/',
      code: 'https://github.com/open-circle/valibot'
    }

    # https://github.com/open-circle/valibot/blob/main/LICENSE.md
    options[:attribution] = <<-HTML
      &copy; Fabian Hiller<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('valibot', opts)
    end

    # valibot.dev serves a Markdown version of every page at the same URL with a
    # `.md` extension, and indexes all of them in llms.txt. Scraping those rather
    # than the HTML pages saves us from stripping the framework noise Qwik leaves
    # in the server-rendered markup (`<!--qv-->` comments and `q:*` attributes on
    # nearly every node), and llms.txt also tells us which section a page belongs
    # to, which is what the entry types are built from.
    INDEX_PATH = 'llms.txt'

    # The llms.txt sections to scrape. The blog is left out: those posts are
    # release announcements and design write-ups, not documentation.
    SECTIONS = ['Guides', 'API reference'].freeze

    # The guide that becomes the documentation's root page.
    ROOT_SOURCE_PATH = 'guides/introduction'

    # A documentation page as listed in llms.txt. `source_path` is the path on
    # valibot.dev, `path` the one used inside DevDocs (see #index_page).
    Page = Struct.new(:name, :type, :path, :source_path)

    # `path` is either a DevDocs path or the path of the page on valibot.dev,
    # which only differ for the API reference types (see #index_page).
    def build_page(path)
      path = path.delete_prefix('/')
      page = pages_by_path[path] || pages_by_source_path[path]
      raise "#{self.class.name}: #{path.inspect} isn't listed in #{INDEX_PATH}" if page.nil?

      response = request_one(source_url_for(page))
      result = render(page, body_of(response)) if process_response?(response)
      yield result if block_given?
      result
    end

    def build_pages
      pages_by_url = pages_by_source_path.values.index_by { |page| source_url_for(page) }
      instrument 'running.scraper', urls: pages_by_url.keys

      request_all pages_by_url.keys do |response|
        if process_response?(response)
          yield render(pages_by_url[response.url.to_s], body_of(response))
        else
          instrument 'ignore_response.scraper', response: response
        end
        nil # returning an Array would queue its values as additional URLs
      end
    end

    private

    # The pages are fetched as Markdown (`text/markdown`), which the inherited
    # implementation rejects because it isn't an HTML content type.
    def process_response?(response)
      raise "Error status code (#{response.code}): #{response.url}" if response.error?
      raise "Empty response body: #{response.url}" if response.blank?
      response.success?
    end

    # Typhoeus hands back binary strings, whereas the documentation is UTF-8.
    def body_of(response)
      response.body.dup.force_encoding(Encoding::UTF_8)
    end

    def index_pages
      @index_pages ||= parse_index(body_of(request_one(url_for(INDEX_PATH))))
    end

    def pages_by_path
      @pages_by_path ||= index_pages.index_by(&:path)
    end

    def pages_by_source_path
      @pages_by_source_path ||= index_pages.index_by(&:source_path)
    end

    def source_url_for(page)
      url_for "#{page.source_path}.md"
    end

    # llms.txt is a flat Markdown document: `## Section`, `### Subsection` and
    # `- [Name](url.md)` lines, in that order.
    INDEX_ENTRY_REGEXP = /\A- \[(?<name>.+)\]\((?<url>\S+\.md)\)/

    def parse_index(body)
      section = subsection = nil

      body.each_line.filter_map do |line|
        case line
        when /\A## (.+)/
          section, subsection = $1.strip, nil
          nil
        when /\A### (.+)/
          subsection = $1.strip
          nil
        when INDEX_ENTRY_REGEXP
          name, url = $~[:name], $~[:url]
          next unless SECTIONS.include?(section) && url.start_with?(base_url.to_s)
          index_page name, section, subsection, url[base_url.to_s.length..].delete_suffix('.md')
        end
      end
    end

    def index_page(name, section, subsection, source_path)
      if section == 'Guides'
        path = source_path == ROOT_SOURCE_PATH ? 'index' : source_path
        # The guide subsections overlap with the API reference ones ("Schemas"),
        # so they are prefixed to keep the two apart in the sidebar.
        type = "Guides: #{subsection}"
      else
        # DevDocs paths are case-insensitive (see NormalizePathsFilter), but
        # Valibot names most of its types after the function they belong to
        # (`Enum` vs `enum`). Types therefore get their own subdirectory.
        basename = File.basename(source_path).downcase
        path = subsection == 'Types' ? "api/types/#{basename}" : "api/#{basename}"
        type = subsection
      end

      Page.new(name, type, path, source_path)
    end

    def render(page, body)
      output = markdown_renderer.render(strip_markdown_note(body))
      output = fix_code_blocks(output)
      output = fix_links(output, page)
      output << attribution_for(page)

      { path: page.path, store_path: "#{page.path}.html", output: output, entries: [entry_for(page)] }
    end

    def entry_for(page)
      # The root page is the documentation itself and has no name or type.
      page.path == 'index' ? Entry.new(nil, 'index', nil) : Entry.new(page.name, page.path, page.type)
    end

    # Every page opens with a note pointing at its HTML version and at llms.txt,
    # which is meaningless inside DevDocs.
    MARKDOWN_NOTE_REGEXP = /^> This document is the Markdown version of [^\n]+\n\n?/

    def strip_markdown_note(body)
      body.sub MARKDOWN_NOTE_REGEXP, ''
    end

    # DevDocs highlights <pre> elements based on their data-language attribute.
    def fix_code_blocks(html)
      html.gsub(%r{<pre><code class="([^"]+)">}) { %(<pre data-language="#{$1}"><code>) }
    end

    def fix_links(html, page)
      html.gsub(/href="(\/[^"]*)"/) { %(href="#{fix_link($1, page)}") }
    end

    def fix_link(href, page)
      path, _, fragment = href.partition('#')
      path = path.delete_prefix('/')

      if (target = pages_by_source_path[path.delete_suffix('.md')])
        path = relative_path_from(page.path, target.path)
      else
        # Anything that isn't scraped (the blog, the playground, the thesis PDF)
        # is linked to the website instead.
        path = File.join(base_url.to_s, path.sub(/\.md\z/, '/'))
      end

      fragment.empty? ? path : "#{path}##{fragment}"
    end

    def relative_path_from(path, other_path)
      Pathname.new(other_path).relative_path_from(File.dirname(path)).to_s
    end

    # Mirrors AttributionFilter, which isn't in the pipeline because these pages
    # never go through it. The link points at the HTML version of the page.
    def attribution_for(page)
      url = File.join(base_url.to_s, page.source_path, '/')
      <<-HTML.strip_heredoc
      <div class="_attribution">
        <p class="_attribution-p">
          #{options[:attribution].strip_heredoc.delete "\n"}<br>
          <a href="#{url}" class="_attribution-link">#{url}</a>
        </p>
      </div>
      HTML
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(with_toc_data: true),
        autolink: true,
        fenced_code_blocks: true,
        no_intra_emphasis: true,
        strikethrough: true,
        tables: true
      )
    end
  end
end
