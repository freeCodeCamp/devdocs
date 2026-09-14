require 'cgi'
require 'docs/mdn_content/css'

module Docs
  module MdnContent
    # Builds the parts of a page that MDN generates out of data rather than out
    # of markdown: the Baseline indicator, the status note cards, and the
    # specifications and browser compatibility tables.
    class Generator
      BROWSERS = {
        'Desktop' => {
          'chrome' => 'Chrome',
          'edge' => 'Edge',
          'firefox' => 'Firefox',
          'opera' => 'Opera',
          'safari' => 'Safari'
        },
        'Mobile' => {
          'chrome_android' => 'Chrome Android',
          'firefox_android' => 'Firefox for Android',
          'opera_android' => 'Opera Android',
          'safari_ios' => 'Safari on iOS',
          'samsunginternet_android' => 'Samsung Internet',
          'webview_android' => 'WebView Android',
          'webview_ios' => 'WebView on iOS'
        },
        'Server' => {
          'bun' => 'Bun',
          'deno' => 'Deno',
          'nodejs' => 'Node.js'
        }
      }.freeze

      # https://github.com/mdn/yari/blob/main/client/src/lit/baseline-indicator.ts
      BASELINE = {
        'high' => ['high', 'Widely available', <<~TEXT],
          This feature is well established and works across many devices and
          browser versions.
        TEXT
        'low' => ['low', 'Newly available', <<~TEXT],
          This feature works across the latest devices and browser versions.
          This feature might not work in older devices or browser versions.
        TEXT
        'false' => ['not', 'Limited availability', <<~TEXT]
          This feature is not Baseline because it does not work in some of the
          most widely-used browsers.
        TEXT
      }.freeze

      STATUSES = {
        'deprecated' => ['deprecated', 'Deprecated', <<~TEXT],
          This feature is no longer recommended. Though some browsers might
          still support it, it may have already been removed from the relevant
          web standards, may be in the process of being dropped, or may only be
          kept for compatibility purposes. Avoid using it, and update existing
          code if possible; see the <a href="#browser_compatibility">compatibility
          table</a> at the bottom of this page to guide your decision. Be aware
          that this feature may cease to work at any time.
        TEXT
        'experimental' => ['experimental', 'Experimental', <<~TEXT],
          <strong>This is an experimental technology</strong><br>Check the
          <a href="#browser_compatibility">Browser compatibility table</a>
          carefully before using this in production.
        TEXT
        'non-standard' => ['nonstandard', 'Non-standard', <<~TEXT]
          This feature is non-standard and is not on a standards track. Do not
          use it on production sites facing the Web: it will not work for every
          user. There may also be large incompatibilities between implementations
          and the behavior may change in the future.
        TEXT
      }.freeze

      def initialize(data)
        @data = data
      end

      # The sections MDN builds out of mdn-data, on the CSS pages only.
      def css
        @css ||= Css.new(@data)
      end

      # Everything MDN puts above the content of a page: its title, how widely
      # available the feature is, and whether it should be used at all.
      def header(page)
        html = +%(<h1>#{escape page.title}</h1>)
        html << baseline(page.browser_compat.first).to_s
        page.status.each { |status| html << note_card(*STATUSES[status]) if STATUSES.key?(status) }
        html
      end

      def note_card(name, title, text)
        %(<div class="notecard #{name}"><p><strong>#{title}:</strong> #{text.squish}</p></div>)
      end

      def baseline(query)
        return unless query && (status = @data.baseline(query))
        name, title, text = BASELINE[status['baseline'].to_s]
        return unless name

        text = "#{text.squish} It's been available across browsers since #{month status['baseline_low_date']}." if status['baseline_low_date']

        <<~HTML.squish
          <details class="baseline-indicator #{name}">
            <summary><div class="status-title">Baseline <span class="not-bold">#{title}</span></div></summary>
            <div class="extra"><p>#{text.squish}</p></div>
          </details>
        HTML
      end

      # The sections of browser-compat-data MDN lists the server-side runtimes
      # for. The web APIs have data for them too, but no column.
      SERVER_SECTIONS = %w(javascript webassembly)

      # The browser compatibility table of one or more features, e.g.
      # "javascript.builtins.Array.map".
      def compat(queries)
        features = queries.flat_map { |query| compat_features(query) }
        return if features.empty?

        browsers = BROWSERS
        browsers = browsers.except('Server') unless queries.any? { |query| SERVER_SECTIONS.include?(query.split('.').first) }
        ids = browsers.each_value.flat_map(&:keys)

        rows = features.map do |name, support|
          cells = ids.map { |id| support_cell id, support[id] }
          %(<tr><th><code>#{escape name}</code></th>#{cells.join}</tr>)
        end

        <<~HTML
          <table class="bc-table">
            <thead>
              <tr>#{['<th></th>', *browsers.map { |platform, names| %(<th colspan="#{names.size}">#{platform}</th>) }].join}</tr>
              <tr>#{['<th></th>', *browsers.each_value.flat_map(&:values).map { |name| "<th>#{name}</th>" }].join}</tr>
            </thead>
            <tbody>#{rows.join}</tbody>
          </table>
        HTML
      end

      # The specifications a feature is defined in. They're looked up in
      # browser-compat-data unless the page names them itself.
      def specifications(queries, urls)
        urls = specification_urls(queries, urls)
        return if urls.empty?

        rows = urls.map do |url|
          title = specification_title(url)
          fragment = url[/#(.+)\z/, 1]
          title = %(#{escape title}<br># #{escape fragment}) if fragment
          %(<tr><td><a href="#{escape escape_url(url)}">#{title}</a></td></tr>)
        end

        <<~HTML
          <table>
            <thead><tr><th scope="col">Specification</th></tr></thead>
            <tbody>#{rows.join}</tbody>
          </table>
        HTML
      end

      # The names of the specifications a feature is defined in, which is how
      # the entries filters tell one part of a documentation from another.
      def specification_titles(queries, urls)
        specification_urls(queries, urls).map { |url| specification_title url }
      end

      private

      UNKNOWN_SPECIFICATION = 'Unknown specification'

      def specification_urls(queries, urls)
        urls = queries.flat_map { |query| spec_urls @data.compat(query) } if urls.empty?
        urls.uniq
      end

      def specification_title(url)
        @data.spec(url)&.fetch('title') || UNKNOWN_SPECIFICATION
      end

      # The feature itself, when it has compatibility data of its own, followed
      # by its subfeatures. A subfeature can go by the name of the feature —
      # the constructor of Intl.Locale is javascript.builtins.Intl.Locale.Locale
      # — hence the pairs rather than a hash.
      def compat_features(query)
        return [] unless (data = @data.compat(query))

        features = []
        features << [query.split('.').last, data] if data.key?('__compat')
        data.each { |key, value| features << [key, value] if value.is_a?(Hash) && value.key?('__compat') }
        features.map { |name, feature| [name, feature['__compat']['support'] || {}] }
      end

      # The first statement is the current one; the ones that follow it are the
      # versions the feature was supported in before, under a prefix or a flag.
      def support_cell(browser, support)
        statements = Array.wrap(support)
        return %(<td class="bc-supports-unknown"><div>?</div></td>) if statements.empty?

        versions = statements.map { |statement| support_version browser, statement }
        %(<td class="bc-supports-#{support_level statements.first}">#{versions.join}</td>)
      end

      def support_level(statement)
        return 'no' if statement['version_added'] == false || statement['version_removed']
        return 'preview' if statement['version_added'] == 'preview'
        return 'unknown' if statement['version_added'].nil?
        return 'partial' if statement['partial_implementation'] || statement['flags']
        'yes'
      end

      def support_version(browser, statement)
        added = statement['version_added']
        version = case added
                  when true then 'Yes'
                  when false then 'No'
                  when nil then '?'
                  else added
                  end

        version = "#{version}–#{statement['version_removed']}" if statement['version_removed'].is_a?(String)

        if added.is_a?(String) && (date = @data.release_date(browser, added))
          version = %(<abbr title="Release date: #{date}">#{escape version}</abbr>)
        else
          version = escape version
        end

        notes = Array.wrap(statement['notes'])
        return "<div>#{version}</div>" if notes.empty?
        %(<details><summary>#{version}</summary>#{notes.join('<br>')}</details>)
      end

      # The specification urls of a feature, or of its subfeatures when it has
      # none of its own.
      def spec_urls(data)
        return [] unless data.is_a?(Hash)
        return Array.wrap(data.dig('__compat', 'spec_url')) if data.key?('__compat')
        data.each_value.flat_map { |value| spec_urls value }
      end

      def month(date)
        Date.parse(date).strftime('%B %Y')
      rescue ArgumentError, TypeError
        date
      end

      def escape(text)
        CGI.escape_html text.to_s
      end

      # The urls of browser-compat-data point at the fragment the browsers gave
      # a section of a specification, which is neither always ascii nor always
      # escaped — %symbol.iterator% is a fragment, not an escape.
      def escape_url(url)
        url.gsub(/%(?![0-9A-Fa-f]{2})|[^\x21-\x7E]/) { |char| char.bytes.map { |byte| format('%%%02X', byte) }.join }
      end
    end
  end
end
