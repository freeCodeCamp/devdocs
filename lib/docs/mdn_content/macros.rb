require 'cgi'
require 'strscan'

module Docs
  module MdnContent
    # Expands the KumaScript macro calls MDN leaves in its markdown, e.g.
    # {{jsxref("Array")}} or {{Compat}}. Only the macros the JavaScript
    # reference uses are implemented; the others are dropped.
    #
    # See https://github.com/mdn/yari/tree/main/kumascript/macros.
    class Macros
      DOCS = '/en-US/docs'
      JAVASCRIPT = 'Web/JavaScript/Reference'
      CSS = 'Web/CSS'
      GLOBAL_OBJECTS = 'Global_Objects'

      # Where the CSS reference files its pages, which is what the names a
      # cssxref goes by have to be looked for under.
      CSS_SECTIONS = ['', 'Properties/', 'Values/', 'Selectors/', 'At-rules/']

      # The macros whose expansion replaces the paragraph holding them rather
      # than sitting inside it.
      BLOCK = /\A<(?:table|div|details|pre|[uo]l|h\d)[\s>]/

      CALL = /\{\{\s*([\w.-]+)/

      def initialize(page, pages, generator)
        @page = page
        @pages = pages
        @generator = generator
      end

      def expand?(text)
        text.include?('{{')
      end

      # Replaces the macro calls in a string of text with their expansion,
      # which is HTML — hence the escaping of everything around them. Anything
      # that doesn't parse as a call is left alone.
      def expand(text)
        scanner = StringScanner.new(text)
        result = +''

        until scanner.eos?
          result << CGI.escape_html(scanner.scan_until(/(?=\{\{)/).to_s)
          break if scanner.eos?

          if (call = parse(scanner))
            result << call_macro(*call).to_s
          else
            result << CGI.escape_html(scanner.getch)
          end
        end

        result << CGI.escape_html(scanner.rest)
      end

      def block?(html)
        html.match? BLOCK
      end

      private

      def parse(scanner)
        position = scanner.pos
        return revert(scanner, position) unless scanner.skip(/\{\{\s*/) && (name = scanner.scan(/[\w.-]+/))

        arguments = []

        if scanner.skip(/\s*\(/)
          until scanner.skip(/\s*\)/)
            argument =
              if scanner.scan(/\s*"((?:[^"\\]|\\.)*)"/) ||
                 scanner.scan(/\s*'((?:[^'\\]|\\.)*)'/) ||
                 scanner.scan(/\s*`([^`]*)`/)
                scanner[1]
              else
                # An argument can be left out, as in {{rfc("7002",,"3.2")}},
                # in which case there's nothing to scan but a comma follows.
                scanner.scan(/[^,)]+/) || ('' if scanner.match?(/,/))
              end

            # Anything else isn't a call, and would have the scanner stand
            # still until the end of time.
            return revert(scanner, position) if argument.nil?

            # The arguments are written the way they read, which for the names
            # of the CSS types means &lt;color&gt; rather than <color>.
            arguments << CGI.unescape_html(argument.strip)
            scanner.skip(/\s*,/)
          end
        end

        return revert(scanner, position) unless scanner.skip(/\s*\}\}/)
        [name, arguments]
      end

      def revert(scanner, position)
        scanner.pos = position
        nil
      end

      def call_macro(name, arguments)
        name = name.downcase.tr('-', '_')
        return unless MACROS.include?(name)
        send(name, *arguments)
      rescue ArgumentError
        nil
      end

      #
      # Cross-references
      #

      def jsxref(api, display = nil, anchor = nil, plain = nil)
        slug = api.sub('()', '').sub('.prototype.', '.')
        slug = slug.sub('.', '/') if api.include?('.') && !api.include?('/')
        content = content_for(display || api, plain)

        if documents?(JAVASCRIPT)
          slug = "#{GLOBAL_OBJECTS}/#{slug}" if !@pages.include?(slug) && @pages.include?("#{GLOBAL_OBJECTS}/#{slug}")
          return content unless @pages.include?(slug)
        end

        link "#{DOCS}/#{JAVASCRIPT}/#{slug}#{fragment anchor}", content
      end

      def domxref(api, display = nil, anchor = nil, plain = nil)
        slug = api.tr(' ', '_').remove('()').gsub('.prototype.', '.').tr('.', '/').sub(/\A./, &:upcase)
        display = display.presence || api
        display = "#{display}.#{anchor}" if anchor.present?
        link "#{DOCS}/Web/API/#{slug}#{fragment anchor}", content_for(display, plain)
      end

      def glossary(term, display = nil, plain = nil)
        link "#{DOCS}/Glossary/#{term.tr(' ', '_')}", content_for(display || term, plain || '1')
      end

      # The CSS reference files a name under one of its sections and spells it
      # the way the section does — the page of the "length" type is
      # Values/length and goes by <length>. Outside the CSS documentation, the
      # link is the one MDN redirects from.
      def cssxref(name, display = nil, anchor = nil)
        page = css_page(name) if documents?(CSS)
        display = display.presence || page&.short_title || name
        slug = page ? page.slug : css_name(name)
        link "#{DOCS}/#{CSS}#{'/Reference' if page}/#{slug}#{fragment anchor}", content_for(display, nil)
      end

      def css_page(name)
        name = css_name(name)
        CSS_SECTIONS.each do |section|
          page = @pages["#{section}#{name}"] || @pages["#{section}#{name}_value"]
          return page if page
        end
        nil
      end

      # A type is referred to as <color> and a function as calc(), neither of
      # which is part of the name of their page.
      def css_name(name)
        name.remove('()').remove(/\A<|>\z/)
      end

      # Whether the documentation being built is the one a cross-reference
      # points into, rather than one linking out to it.
      def documents?(prefix)
        @pages.prefix.start_with?(prefix)
      end

      def htmlelement(name, display = nil, anchor = nil)
        name = name.downcase
        display = display.presence || "<#{name}>"
        link "#{DOCS}/Web/HTML/Element/#{name}#{fragment anchor}", content_for(display, nil)
      end

      def httpheader(name, display = nil, anchor = nil, plain = nil)
        display = display.presence || name
        display = "#{display}.#{anchor}" if anchor.present?
        link "#{DOCS}/Web/HTTP/Headers/#{name}#{fragment anchor}", content_for(display, plain)
      end

      def svgelement(name, *)
        link "#{DOCS}/Web/SVG/Reference/Element/#{name}", content_for("<#{name}>", nil)
      end

      def svgattr(name, *)
        link "#{DOCS}/Web/SVG/Reference/Attribute/#{name}", content_for(name, nil)
      end

      def mathmlelement(name, display = nil, anchor = nil)
        display = display.presence || "<#{name}>"
        link "#{DOCS}/Web/MathML/Reference/Element/#{name}#{fragment anchor}", content_for(display, nil)
      end

      def httpmethod(name, display = nil, anchor = nil, plain = nil)
        link "#{DOCS}/Web/HTTP/Reference/Methods/#{name}#{fragment anchor}", content_for(display.presence || name, plain)
      end

      def csp(directive, *)
        link "#{DOCS}/Web/HTTP/Reference/Headers/Content-Security-Policy/#{directive}", content_for(directive, nil)
      end

      def httpstatus(code, display = nil, anchor = nil, plain = nil)
        link "#{DOCS}/Web/HTTP/Reference/Status/#{code}#{fragment anchor}", content_for(display.presence || code, plain)
      end

      def webextapiref(name, display = nil, *)
        slug = name.tr('.', '/')
        link "#{DOCS}/Mozilla/Add-ons/WebExtensions/API/#{slug}", content_for(display.presence || name, nil)
      end

      def rfc(number, title = nil, section = nil)
        url = "https://datatracker.ietf.org/doc/html/rfc#{number}"
        text = +"RFC #{number}"

        if section.present?
          url << "#section-#{section}"
          text << ", section #{section}"
        end

        text << ": #{title}" if title.present?
        link url, escape(text)
      end

      #
      # Badges and note cards
      #

      def optional_inline
        %(<span class="badge inline optional">Optional</span>)
      end

      def deprecated_inline
        badge 'deprecated', 'Deprecated', 'Deprecated. Not for use in new websites.'
      end

      def experimental_inline
        badge 'experimental', 'Experimental', 'Experimental. Expect behavior to change in the future.'
      end

      def non_standard_inline
        badge 'nonStandard', 'Non-standard', 'Non-standard. Check cross-browser support before using.'
      end

      def readonlyinline
        %(<span class="badge inline readonly">Read only</span>)
      end

      def securecontext_inline
        %(<span class="badge inline secure">Secure context</span>)
      end

      def securecontext_header
        @generator.note_card 'secure', 'Secure context', <<~TEXT
          This feature is available only in <a href="#{DOCS}/Web/Security/Secure_Contexts">secure
          contexts</a> (HTTPS), in some or all <a href="#browser_compatibility">supporting browsers</a>.
        TEXT
      end

      # https://github.com/mdn/yari/blob/main/kumascript/macros/AvailableInWorkers.ejs
      WORKERS = "<a href=\"#{DOCS}/Web/API/Web_Workers_API\">Web Workers</a>"
      SERVICE_WORKERS = "<a href=\"#{DOCS}/Web/API/Service_Worker_API\">Service Workers</a>"

      WORKER_SCOPES = {
        nil => "This feature is available in #{WORKERS}.",
        'worker' => "This feature is only available in #{WORKERS}.",
        'window_and_worker_except_service' => "This feature is available in #{WORKERS}, except for #{SERVICE_WORKERS}.",
        'worker_except_service' => "This feature is only available in #{WORKERS}, except for #{SERVICE_WORKERS}.",
        'window_and_worker_except_shared' => %(This feature is available in #{WORKERS}, except for <a href="#{DOCS}/Web/API/SharedWorkerGlobalScope">Shared Web Workers</a>.),
        'window_and_dedicated' => %(This feature is available in <a href="#{DOCS}/Web/API/DedicatedWorkerGlobalScope">Dedicated Web Workers</a>.),
        'dedicated' => %(This feature is only available in <a href="#{DOCS}/Web/API/DedicatedWorkerGlobalScope">Dedicated Web Workers</a>.),
        'window_and_service' => "This feature is available in #{SERVICE_WORKERS}.",
        'service' => "This feature is only available in #{SERVICE_WORKERS}."
      }

      def availableinworkers(scope = nil)
        @generator.note_card 'note', 'Note', WORKER_SCOPES.fetch(scope.presence, WORKER_SCOPES[nil])
      end

      def seecompattable
        @generator.note_card(*Generator::STATUSES['experimental'])
      end

      def non_standard_header
        @generator.note_card(*Generator::STATUSES['non-standard'])
      end

      def deprecated_header
        @generator.note_card(*Generator::STATUSES['deprecated'])
      end

      #
      # Generated sections
      #

      def compat(query = nil)
        @generator.compat(queries(query, @page.browser_compat))
      end

      def specifications(query = nil)
        @generator.specifications(queries(query, @page.browser_compat), @page.spec_urls)
      end

      def interactiveexample(*)
        %(<h2 id="try_it">Try it</h2>)
      end

      # The index of a landing page. MDN nests it as deep as it's asked to;
      # one level is all its own pages ever ask for.
      def listsubpages(path = nil, _depth = nil, reverse = nil, ordered = nil)
        children = children_of(path)
        return if children.empty?

        children = children.reverse if reverse.to_s == '1'
        items = children.map { |child| %(<li>#{link "#{DOCS}/#{@pages.prefix}/#{child.slug}", escape(child.title)}</li>) }
        tag = ordered.to_s == '1' ? 'ol' : 'ul'
        "<#{tag}>#{items.join}</#{tag}>"
      end

      def csssyntax(*)
        @generator.css.syntax @page
      end

      def csssyntaxraw(syntax)
        @generator.css.raw_syntax syntax
      end

      def cssinfo(name = nil, at_rule = nil)
        @generator.css.info @page, name.presence, at_rule.presence
      end

      def js_property_attributes(writable, enumerable, configurable)
        rows = { 'Writable' => writable, 'Enumerable' => enumerable, 'Configurable' => configurable }
        rows = rows.map { |name, value| "<tr><td>#{name}</td><td>#{value.to_s == '1' ? 'yes' : 'no'}</td></tr>" }

        <<~HTML
          <table class="standard-table">
            <thead><tr><th colspan="2">Property attributes of <code>#{escape @page.title}</code></th></tr></thead>
            <tbody>#{rows.join}</tbody>
          </table>
        HTML
      end

      # MDN follows every link of this index with the opening paragraph of the
      # page it points at. Reading all of those pages to summarize them is a
      # lot of work for the handful of landing pages asking for it, so the
      # index is the same one ListSubPages renders.
      alias_method :subpageswithsummaries, :listsubpages

      # What a page carries none of into DevDocs: the sidebars, the live
      # samples, the inheritance diagrams and the links to the next page.
      DROPPED = %w(
        addonsidebar apiref cssref css_ref defaultapisidebar htmlsidebar jsref
        jssidebar mathmlref svgref webextsidebar
        embedghlivesample embedlivesample embedyoutube livesamplelink
        inheritancediagram previousnext previous next previousmenunext
        previousmenu nextmenu listgroups apilistalpha)

      DROPPED.each { |name| define_method(name) { |*| nil } }

      MACROS = (%w(
        jsxref domxref glossary cssxref htmlelement httpheader httpmethod rfc
        svgelement svgattr mathmlelement csp httpstatus webextapiref
        optional_inline deprecated_inline experimental_inline non_standard_inline
        readonlyinline securecontext_inline
        seecompattable non_standard_header deprecated_header securecontext_header
        availableinworkers
        compat specifications interactiveexample js_property_attributes
        csssyntax csssyntaxraw cssinfo
        listsubpages subpageswithsummaries) + DROPPED).to_set.freeze

      #
      # Helpers
      #

      def children_of(path)
        @pages.children path.to_s.sub(%r{\A/[^/]+/docs/}, '').sub(%r{\A#{Regexp.escape @pages.prefix}/?}, '')
      end

      def queries(query, default)
        query.present? ? query.split(',').map(&:strip) : default
      end

      def content_for(text, plain)
        text = escape(text)
        plain.present? ? text : "<code>#{text}</code>"
      end

      def escape(text)
        CGI.escape_html text.to_s
      end

      def fragment(anchor)
        "##{anchor.delete_prefix('#')}" if anchor.present?
      end

      def link(url, content)
        %(<a href="#{escape url}">#{content}</a>)
      end

      # DevDocs styles the class of the inner element, MDN the icon around it.
      def badge(name, title, description)
        %(<abbr class="icon icon-#{name.downcase}" title="#{description}"><span class="#{name}">#{title}</span></abbr>)
      end
    end
  end
end
