module Docs
  class Jekyll
    class CleanHtmlFilter < Filter
      def call
        css('.improve, .section-nav').each(&:remove)

        css('div.highlighter-rouge').each do |node|
          pre = node.at_css('pre')

          # copy over the highlighting metadata
          match = /language-(\w+)/.match(node['class'])
          # HACK: Prism shell highlighting highlights `|`,
          # which makes the tree on this page look terrible
          if match && !(slug == /structure/ && match[1] == 'sh')
            lang = match[1]
            if lang == 'sh'
              lang = 'bash'
            elsif lang == 'liquid'
              lang = 'django' # Close enough.
            end
            pre['class'] = nil
            pre['data-language'] = lang
          end

          # Remove the server-rendered syntax highlighting
          code = pre.at_css('code')
          code.content = code.text

          # Remove the div.highlighter-rouge and div.highlight wrapping the <pre>
          node.add_next_sibling pre
          node.remove
        end

        css('code').each do |node|
          node['class'] = ''
        end

        css('.note').each do |node|
          node_type = /note ?(\w+)?/.match(node['class'])[1] || 'tip'

          # <div class="note">...<br>...</div> -> <div class="note">...</div>
          (node > 'br').each(&:remove)
          # <div class="note">...<p>...<br><br>...</p>...</div> ->
          # <div class="note">...<p>...<br>...</p>...</div>
          node.css('br + br').each(&:remove)

          node['class'] = "note note-#{node_type}"
          node['data-type'] = node_type
        end

        doc
      end
    end
  end
end
