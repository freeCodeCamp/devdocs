module Docs
  class Love
    class CleanHtmlFilter < Filter
      def call
        # Fix syntax highlighting
        css('.mw-code').each do |node|
          node.content = node.at_css("div > pre").content
          node['data-language'] = 'lua'
          node.name = 'pre'
        end

        # Move header tags up
        css('h2', 'h3').each do |node|
          headline = node.at_css('.mw-headline')
          node['id'] = headline['id']
          node.content = headline.inner_text
        end

        # Move dt tags up
        css('dt > span').each do |node|
          node.parent.content = node.inner_text
        end

        # Style notices and new/removed sections
        css('.notice', '.new-section', '.removed-section', '.removed-new-section').each do |node|
          case node['class']
          when 'notice'
            node['class'] = 'note note-warning'
            node.inner_html = node.at_css('td:nth-child(2)').inner_html
            node.next.remove unless node.next.nil? or node.next.name != 'br'
          when 'new-section', 'removed-section', 'removed-new-section'
            node['class'] = node['class'] == 'new-section' ? 'note note-green' : 'note note-red'
            node.inner_html = node.at_css('tr > td > i').inner_html \
              + '<br>' \
              + node.at_css('tr > td > small').inner_html
          end

          node.name = 'p'
          node.remove_attribute('bgcolor')
          node.remove_attribute('style')
          node.remove_attribute('align')
        end

        # Style new/removed features
        css('.new-feature', '.removed-feature', '.removed-new-feature').each do |node|
          node.name = 'div'
          node['class'] = node['class'] == 'new-feature' ? 'box-heading label-green' : 'box-heading label-red'
          node.remove_attribute('style')

          container = node.next_element
          container.name = 'div'
          container['class'] = 'box-with-heading'
          container.remove_attribute('style')
        end

        # Style tables
        css('table.smwtable').each do |table|
          table.remove_attribute('style')
          table.css('td').each do |cell|
            cell.remove_attribute('style')
          end
          table.css('td:last-child', 'td:nth-last-child(2)').each do |cell|
            img = cell.at_css('img')
            if img then
              if img['alt'] == 'Added since' then
                cell['class'] = 'cell-green'
              elsif img['alt'] == 'Removed in'
                cell['class'] = 'cell-red'
              end
              img.remove
            end
          end
        end

        # Remove Other Languages
        css('#Other_Languages').remove
        css('.i18n').remove

        # Remove changelog
        node = at_css('h2#Changelog')
        if !node.nil? then
          begin
            nxt = node.next
            node.remove
            node = nxt
          end while !node.nil? and node.name != 'h2'
        end

        # Remove empty paragraphs
        css('p').each do |node|
          node.remove if node.inner_text.strip == ''
        end

        # Remove linebreaks that are the first or last child of a paragraph
        css('p > br:first-child', 'p > br:last-child').each do |node|
          node.remove
        end

        doc
      end
    end
  end
end
