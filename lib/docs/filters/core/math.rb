# frozen_string_literal: true

module Docs
  # Replaces the math markup emitted by documentation generators with native
  # MathML, rendered at scrape time by MathRenderer (KaTeX).
  #
  # Only explicit markup is recognized:
  # - Sphinx/MathJax: <span class="math">\(...\)</span> and <div class="math">\[...\]</div>
  # - MathJax 2: <script type="math/tex">...</script> and type="math/tex; mode=display"
  # - MathJax 3: <mjx-container> (keeps its assistive MathML, if any)
  # - KaTeX: pre-rendered <span class="katex"> nodes (re-rendered from their TeX source)
  # - Dollar delimiters ($...$ and $$...$$) in text, only when context[:math_dollars] is true
  # Existing <math> elements are left untouched.
  #
  # This filter must run before CleanHtmlFilter, which removes <script> nodes.
  class MathFilter < Filter
    TEX_DELIMITERS_RGX = /\\\((.*?)\\\)|\\\[(.*?)\\\]/m
    DOLLARS_RGX = /\$\$(?<display>[^$]+?)\$\$|(?<![\\$\w])\$(?<inline>[^\s$](?:[^$\n]*?[^\s$\\])?)\$(?![\d$])/
    TEX_ANNOTATION = 'annotation[encoding="application/x-tex"]'

    def call
      @items = []
      extract_sphinx
      extract_mathjax2
      extract_mathjax3
      extract_katex
      extract_dollars if context[:math_dollars]
      render
      doc
    end

    private

    def extract_sphinx
      css('span.math', 'div.math').each do |node|
        node.css('.eqno').remove
        content = node.content
        next unless content =~ TEX_DELIMITERS_RGX

        pieces = []
        last = 0
        content.scan(TEX_DELIMITERS_RGX) do
          match = Regexp.last_match
          pieces << match.pre_match[last..] unless match.begin(0) == last
          pieces << [match[1] || match[2], !match[1]]
          last = match.end(0)
        end
        pieces << content[last..] if last < content.length

        queue(node, pieces, id: node['id'])
      end
    end

    def extract_mathjax2
      css('.MathJax_Preview').remove
      css('script[type^="math/tex"]').each do |node|
        display = node['type'].include?('mode=display')
        queue(node, [[node.content, display]])
      end
    end

    def extract_mathjax3
      css('mjx-container').each do |node|
        math = node.at_css('mjx-assistive-mml > math')
        next unless math
        math['display'] = 'block' if node['display'] == 'true'
        node.replace(math)
      end
    end

    def extract_katex
      css('.katex').each do |node|
        wrapper = node.parent if node.parent.try(:[], 'class').to_s.split.include?('katex-display')
        target = wrapper || node
        annotation = node.at_css(TEX_ANNOTATION)
        math = node.at_css('math')
        display = !wrapper.nil? || (math && math['display'] == 'block')

        if annotation
          queue(target, [[annotation.content, display]])
        elsif math
          target.replace(math)
        end
      end
    end

    def extract_dollars
      xpath('.//text()[not(ancestor::pre or ancestor::code or ancestor::script or ancestor::style or ancestor::math)]').each do |node|
        content = node.content
        next unless content =~ DOLLARS_RGX

        pieces = []
        last = 0
        content.scan(DOLLARS_RGX) do
          match = Regexp.last_match
          pieces << match.pre_match[last..] unless match.begin(0) == last
          pieces << [match[:display] || match[:inline], !match[:display].nil?]
          last = match.end(0)
        end
        pieces << content[last..] if last < content.length

        queue(node, pieces)
      end
    end

    def queue(node, pieces, id: nil)
      @items << [node, pieces, id]
    end

    def render
      expressions = @items.flat_map { |_, pieces, _| pieces.grep(Array) }
      return if expressions.empty?

      rendered = MathRenderer.render_all(expressions)

      @items.each do |node, pieces, id|
        html = pieces.map do |piece|
          next CGI.escapeHTML(piece) if piece.is_a?(String)
          tex, display = piece
          result = rendered.shift
          result[:mathml] || MathRenderer.fallback(tex, display: display)
        end.join

        fragment = doc.document.fragment(html)
        fragment.at_css('math')['id'] = id if id && fragment.at_css('math')
        node.replace(fragment)
      end
    end
  end
end
