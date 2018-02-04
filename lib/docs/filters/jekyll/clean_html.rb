module Docs
  class Jekyll
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article')

        at_css('h1').content = 'Jekyll' if root_page?

        css('.improve, .section-nav').remove

        css('div.highlighter-rouge').each do |node|
          pre = node.at_css('pre')

          lang = node['class'][/language-(\w+)/, 1]
          # HACK: Prism shell highlighting highlights `|`,
          # which makes the tree on this page look terrible
          unless slug.include?('structure') && lang == 'sh'
            lang = 'bash' if lang == 'sh'
            pre['data-language'] = lang
          end

          pre.remove_attribute('class')
          pre.content = pre.content
          node.replace(pre)
        end

        css('code').remove_attr('class')

        css('.note').each do |node|
          node.name = 'blockquote'

          # <div class="note">...<br>...</div> -> <div class="note">...</div>
          (node > 'br').each(&:remove)
          # <div class="note">...<p>...<br><br>...</p>...</div> ->
          # <div class="note">...<p>...<br>...</p>...</div>
          node.css('br + br').each(&:remove)
        end

        doc
      end
    end
  end
end
