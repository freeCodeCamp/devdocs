# frozen_string_literal: true

module Docs
  # Replaces Sphinx/MathJax math markup with native MathML, rendered at
  # scrape time by MathRenderer (KaTeX):
  # <span class="math">\(...\)</span> and <div class="math">\[...\]</div>
  # Display environments such as align* are emitted without delimiters.
  class MathFilter < Filter
    TEX_DELIMITERS_RGX = /\\\((.*?)\\\)|\\\[(.*?)\\\]/m
    TEX_ENVIRONMENT_RGX = /\A\s*\\begin\{(\w+\*?)\}.*\\end\{\1\}\s*\z/m

    def call
      items = css('span.math', 'div.math').filter_map do |node|
        node.css('.eqno').remove
        content = node.content
        if content =~ TEX_DELIMITERS_RGX
          [node, split(content)]
        elsif content =~ TEX_ENVIRONMENT_RGX
          [node, [[content.strip, true]]]
        end
      end
      render(items)
      doc
    end

    private

    # Splits text into plain strings and [tex, display] pairs.
    def split(content)
      pieces = []
      last = 0
      content.scan(TEX_DELIMITERS_RGX) do
        match = Regexp.last_match
        pieces << content[last...match.begin(0)] unless match.begin(0) == last
        pieces << [match[1] || match[2], !match[1]]
        last = match.end(0)
      end
      pieces << content[last..] if last < content.length
      pieces
    end

    def render(items)
      expressions = items.flat_map { |_, pieces| pieces.grep(Array) }
      return if expressions.empty?

      rendered = MathRenderer.render_all(expressions)

      items.each do |node, pieces|
        html = pieces.map do |piece|
          next CGI.escapeHTML(piece) if piece.is_a?(String)
          tex, display = piece
          rendered.shift[:mathml] || MathRenderer.fallback(tex, display: display)
        end.join

        fragment = doc.document.fragment(html)
        fragment.at_css('math')['id'] = node['id'] if node['id'] && fragment.at_css('math')
        node.replace(fragment)
      end
    end
  end
end
