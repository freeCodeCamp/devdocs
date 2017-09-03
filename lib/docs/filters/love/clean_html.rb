module Docs
  class Love
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#mw-content-text')

        css('.mw-code').each do |node|
          node.content = node.at_css('div > pre').content
          node['data-language'] = 'lua'
          node.name = 'pre'
        end

        css('span[id]').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('table.notice').each do |node|
          content = node.at_css('td:nth-child(2)').inner_html
          node.replace %(<p class="note">#{content}</p>)
        end

        css('table.new-section', 'table.removed-section', 'table.removed-new-section').each do |node|
          klass = node['class'] == 'new-section' ? 'note-green' : 'note-red'
          content = node.css('td').map(&:inner_html).join('<br>')
          node.replace %(<p class="note #{klass}">#{content}</p>)
        end

        css('.new-feature', '.removed-feature', '.removed-new-feature').each do |node|
          klass = node['class'] == 'new-feature' ? 'label-green' : 'label-red'
          content = node.content.sub(' LÖVE', '')
          label = %( <span class="label #{klass}">#{content}</span>)

          node.next_element.css('dt').each { |n| n << label }
          node.remove
        end

        css('img[src$="Add.png"]').each do |node|
          node.parent['class'] = 'cell-green'
          node.remove
        end

        css('img[src$="Remove.png"]').each do |node|
          node.parent['class'] = 'cell-red'
          node.remove
        end

        css('table, tr, td, th').each do |node|
          %w(style cellpadding cellspacing width height valign).each do |attribute|
            node.remove_attribute(attribute)
          end
        end

        css('.note i', '.note small', 'div:not([class])', '.smwtable td:nth-last-child(2) > a', '.smwtable td:last-child > a').each do |node|
          node.before(node.children).remove
        end

        css('p > br').each do |node|
          node.parent.remove if node.parent.content.empty?
        end

        css('div > br', '> br', 'hr').remove
        css('#Editing_the_wiki + p', '#Editing_the_wiki').remove
        css('#Other_Languages', '.i18n').remove

        doc
      end
    end
  end
end
