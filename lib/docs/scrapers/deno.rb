module Docs
  class Deno < UrlScraper
    self.name = 'Deno'
    self.type = 'deno'
    self.base_url = 'https://docs.deno.com/'
    self.root_path = 'api/'
    self.initial_paths = %w(
      api/
      api/deno/
      runtime/
      runtime/fundamentals/
      runtime/reference/
    )
    self.links = {
      home: 'https://deno.com/',
      code: 'https://github.com/denoland/deno'
    }

    html_filters.push 'deno/clean_html', 'deno/entries'

    options[:root_title] = 'Deno'
    options[:title] = false
    options[:follow_links] = true
    options[:only_patterns] = [
      /\Aapi\//,
      /\Aruntime\//,
    ]
    options[:skip_patterns] = [
      /\Ablog\//,
      /\Adeploy\//,
      /\Asubhosting\//,
    ]

    options[:attribution] = <<-HTML
      &copy; 2018&ndash;2025 the Deno authors<br>
      Licensed under the MIT License.
    HTML

    # ── Versions ──────────────────────────────────────────────────────

    version '2' do
      self.release = '2.3.1'
    end

    version '1' do
      self.release = '1.46.3'
      self.base_url = 'https://docs.deno.com/api/'
    end

    # ── Latest version lookup ─────────────────────────────────────────

    def get_latest_version(opts)
      get_latest_github_release('denoland', 'deno', opts)
    end

    private

    # ── Module categorisation ─────────────────────────────────────────

    MODULE_CATEGORIES = {
      'Deno'        => %w[Deno],
      'Web APIs'    => %w[fetch Request Response Headers URL URLSearchParams
                          FormData Blob File ReadableStream WritableStream
                          TransformStream TextEncoder TextDecoder
                          WebSocket EventSource AbortController AbortSignal
                          crypto CryptoKey SubtleCrypto],
      'I/O'         => %w[open read write close seek],
      'File System' => %w[readFile writeFile readDir mkdir remove rename
                          stat lstat realPath readLink symlink link
                          truncate copyFile chmod chown],
      'Network'     => %w[listen connect serve serveHttp
                          listenTls connectTls],
      'Subprocess'  => %w[run Command ChildProcess],
      'Testing'     => %w[test bench],
      'Permissions' => %w[permissions],
    }.freeze

    def categorize_module(name)
      MODULE_CATEGORIES.each do |category, modules|
        return category if modules.any? { |m| name.include?(m) }
      end
      'Other'
    end

    # ── Page parsing ──────────────────────────────────────────────────

    def parse_page(response)
      doc = Nokogiri::HTML.parse(response.body)
      return nil if doc.at_css('meta[http-equiv="refresh"]')

      content = doc.at_css('main, article, [role="main"], .markdown-body')
      return nil unless content

      # Remove navigation, sidebars, and footers
      content.css('nav, footer, .sidebar, .breadcrumb, .toc,
                   .page-nav, .edit-link, .header-anchor').each(&:remove)

      # Remove script and style tags
      content.css('script, style').each(&:remove)

      content
    end

    # ── Link resolution ───────────────────────────────────────────────

    def resolve_links(content, base_url)
      content.css('a[href]').each do |link|
        href = link['href']
        next if href.nil? || href.empty?
        next if href.start_with?('#')
        next if href.match?(%r{\Ahttps?://}) && !href.start_with?(self.class.base_url)

        begin
          absolute = URI.join(base_url, href).to_s
          link['href'] = absolute
        rescue URI::InvalidURIError
          # Leave malformed URIs as-is
        end
      end
      content
    end

    # ── Code example extraction ───────────────────────────────────────

    def extract_code_examples(content)
      examples = []
      content.css('pre > code, pre.highlight, .code-block').each_with_index do |block, idx|
        lang = detect_language(block)
        source = block.text.strip
        next if source.empty?

        examples << {
          index: idx,
          language: lang,
          source: source,
          lines: source.lines.count,
        }
      end
      examples
    end

    def detect_language(code_node)
      # Check class attribute for language hints
      classes = (code_node['class'] || '').split
      lang_class = classes.find { |c| c.start_with?('language-', 'lang-', 'highlight-') }
      if lang_class
        return lang_class.sub(/\A(?:language|lang|highlight)-/, '')
      end

      # Check data attributes
      data_lang = code_node['data-language'] || code_node['data-lang']
      return data_lang if data_lang

      # Check parent element
      parent = code_node.parent
      if parent
        parent_lang = parent['data-language'] || parent['data-lang']
        return parent_lang if parent_lang

        parent_classes = (parent['class'] || '').split
        parent_lang_class = parent_classes.find { |c| c.start_with?('language-', 'lang-') }
        if parent_lang_class
          return parent_lang_class.sub(/\A(?:language|lang)-/, '')
        end
      end

      'text'
    end

    # ── Version handling ──────────────────────────────────────────────

    def version_url(version, path)
      if version && !version.empty?
        "#{self.class.base_url}#{path}@#{version}"
      else
        "#{self.class.base_url}#{path}"
      end
    end

    def parse_version_from_url(url)
      match = url.match(/@([\d.]+)/)
      match ? match[1] : nil
    end

    def normalize_version(version_string)
      return nil if version_string.nil? || version_string.empty?

      # Strip leading 'v' if present
      cleaned = version_string.sub(/\Av/, '')

      # Validate semver-like format
      parts = cleaned.split('.')
      return nil unless parts.length.between?(1, 3)
      return nil unless parts.all? { |p| p.match?(/\A\d+\z/) }

      cleaned
    end
  end
end
