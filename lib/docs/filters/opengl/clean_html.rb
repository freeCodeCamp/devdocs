module Docs
    class Opengl
      class CleanHtmlFilter < Filter
        def call
          return '<h1>OpenGL</h1>' if root_page?

          @doc = at_css('.refentry') if at_css('.refentry')

          # Remove table from function definitions
          css('.funcprototype-table').each do |node|
            node.css('td').each do |data|
              data.replace(data.children)
            end
            node.css('tr').each do |row|
              row.replace(row.children)
            end
            node.wrap('<div>')
            node.parent['id'] = node.css('.fsfunc').text
            node.replace(node.children)
          end

          css('a').remove_attribute('target')

          # needed for scraper's options[:attribution]
          copyright = at_css('h2:contains("Copyright")')
          copyright.parent['style'] = 'display: none' if copyright

          doc
        end
      end
    end
  end
