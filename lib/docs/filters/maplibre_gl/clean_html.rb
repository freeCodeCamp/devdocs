module Docs
  class MaplibreGl
    class CleanHtmlFilter < Filter
      def call
        # Anchor icons next to headings.
        css('.headerlink').remove

        # The TypeDoc pages carry a "Defined in: <source link>" paragraph on
        # every member; it points at a pinned commit and adds noise.
        css('p').each do |node|
          node.remove if node.content.start_with?('Defined in:')
        end

        # MkDocs Material renders highlighted code as
        # <div class="language-xx highlight"><pre><code>…lots of spans…</code></pre></div>
        # with per-line anchors. Flatten each block to its plain text and tag
        # the language so DevDocs can re-highlight it.
        css('div.highlight').each do |node|
          language = node['class'][/language-(\w+)/, 1]
          pre = node.at_css('pre')
          next unless pre

          pre['data-language'] = language if language
          pre.content = pre.at_css('code').content
          node.replace(pre)
        end

        doc
      end
    end
  end
end
