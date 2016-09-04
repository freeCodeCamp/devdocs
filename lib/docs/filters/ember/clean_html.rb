module Docs
  class Ember
    class CleanHtmlFilter < Filter
      def call
        css('hr', '.edit-page').remove

        # Remove code highlighting
        css('.highlight').each do |node|
          node.before(%(<div class="pre-title"><code>#{node.at_css('thead').content.strip}</code></div>)) if node.at_css('thead')
          node.content = node.at_css('.code pre').content
          node.name = 'pre'
          node['data-language'] = node['class'][/(javascript|js|html|hbs|handlebars)/, 1]
          node['data-language'] = node['data-language'].sub(/(hbs|handlebars)/, 'html')
        end

        if base_url.path.start_with?('/api')
          root_page? ? root : api
        else
          guide
        end

        doc
      end

      def root
        css('#back-to-top').remove

        # Remove "Projects" and "Tag" links
        css('.level-1:nth-child(1)', '.level-1:nth-child(2)').remove

        # Turn section links (e.g. Modules) into headings
        css('.level-1 > a').each do |node|
          node.name = 'h2'
          node.remove_attribute 'href'
        end

        # Remove root-level list
        css('.level-1').each do |node|
          node.before(node.elements).remove
        end

        css('ol').each do |node|
          node.name = 'ul'
        end
      end

      def api
        css('#api-options', '.toc-anchor', '.inherited').remove

        # Remove tabs and "Index"
        css('.tabs').each do |node|
          panes = node.css '#methods', '#events', '#properties'
          panes.remove_attr 'style'
          node.before(panes).remove
        end

        css('.method', '.property', '.event').remove_attr('id')

        css('h3[data-id]').each do |node|
          heading = Nokogiri::XML::Node.new 'h2', doc
          heading['id'] = node['data-id']
          node.before(heading).remove
          heading.content = node.content
          heading.add_child(heading.next_element) while heading.next_element.name == 'span'
        end

        css('> .class-info').each do |node|
          node.name = 'blockquote'
        end

        css('div.meta').each do |node|
          node.name = 'p'
        end

        css('span.type').each do |node|
          node.name = 'code'
        end

        css('.pane', '.item-entry').each do |node|
          node.before(node.children).remove
        end
      end

      def guide
        @doc = at_css('article')

        css('.previous-guide', '.next-guide').remove

        css('img').each do |node|
          node['src'] = node['src'].sub('https://guides.emberjs.com/', base_url.to_s)
        end

        css('h3, h4, h5').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end unless at_css('h2')

        css('blockquote > p > em').each do |node|
          node.before(node.children).remove
        end
      end
    end
  end
end
