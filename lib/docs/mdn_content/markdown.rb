require 'cgi'

module Docs
  module MdnContent
    # Renders the markdown of an MDN page. MDN renders it with remark and the
    # GitHub extensions, which kramdown's GFM parser comes closest to; the
    # constructs that are specific to MDN — its definition lists, note cards
    # and code fences — are turned into what MDN makes of them afterwards, in
    # Javascript::CleanHtmlFilter.
    #
    # kramdown belongs to the docs bundle group, which the app leaves out, and
    # the app loads every scraper to build its manifest. Requiring it here
    # would break that; `Bundler.require :default, :docs` in docs.rb loads it
    # for the scrapers, which are the only ones rendering anything.
    module Markdown
      # MDN's markdown is not typeset: replacing "..." with an ellipsis or "--"
      # with a dash would rewrite the code that's inline in the prose, starting
      # with the names of the "try...catch" and "for...of" pages.
      SYMBOLS = {
        hellip: '...',
        mdash: '---',
        ndash: '--',
        laquo: '<<',
        raquo: '>>',
        laquo_space: '<< ',
        raquo_space: ' >>'
      }

      OPTIONS = {
        input: 'GFM',
        auto_ids: false,
        hard_wrap: false,
        syntax_highlighter: nil,
        smart_quotes: %w(apos apos quot quot),
        typographic_symbols: SYMBOLS
      }

      # The lint switch MDN appends to the name of a language, and the names it
      # gives the blocks that aren't code to begin with.
      NOLINT = '-nolint'
      NOT_A_LANGUAGE = %w(plain none text unix)

      OPENING_FENCE = /\A([ ]{0,3})([~`]{3,})[ \t]*(\S[^\n]*)?\n?\z/

      # A macro call and what it's held out of the parser's reach as, which is
      # a word markdown has no reason to touch.
      MACRO = /\{\{.*?\}\}/m
      TOKEN = /kumascript(\d+)kumascript/

      def self.render(source)
        macros = []
        source = normalize_fences(source).gsub(MACRO) { |macro| "kumascript#{macros.push(macro).size - 1}kumascript" }

        # kramdown edits the options it's handed, hence the copy.
        html = Kramdown::Document.new(source, OPTIONS.deep_dup).to_html
        html.gsub(TOKEN) { CGI.escape_html macros[$1.to_i] }
      end

      # A macro call means nothing to markdown, which is free to read the
      # punctuation in its arguments as emphasis and tear it in half — as in
      # {{jsxref("Statements/function*", "function*")}}. MDN puts its calls out
      # of reach for the same reason; see markdown/utils/index.ts in
      # https://github.com/mdn/yari.
      #
      # Reduces the info string of the code fences to their language. MDN tags
      # them with the role they play in the page as well — "js example-bad",
      # "js interactive-example" — which kramdown doesn't expect, and which
      # makes it miss the fence altogether.
      def self.normalize_fences(source)
        closing = nil

        source.lines.map! do |line|
          if closing
            closing = nil if line.match?(closing)
            line
          elsif (fence = line.match(OPENING_FENCE))
            closing = /\A[ ]{0,3}#{fence[2]}#{fence[2][0]}*[ \t]*\n?\z/
            "#{fence[1]}#{fence[2]}#{language(fence[3])}\n"
          else
            line
          end
        end.join
      end

      def self.language(info)
        name = info.to_s[/\A\S+/].to_s.delete_suffix(NOLINT)
        NOT_A_LANGUAGE.include?(name) ? '' : name
      end
    end
  end
end
