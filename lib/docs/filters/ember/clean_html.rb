module Docs
  class Ember
    class CleanHtmlFilter < Filter
      def call
        css('hr', '.edit-page', '.heading__link__edit', 'aside', '.old-version-warning').remove

        base_url.host.start_with?('api') ? api : guide

        doc
      end

      def api
        # Remove code highlighting
        css('.highlight').each do |node|
          node.before(%(<div class="pre-title"><code>#{node.at_css('thead').content.strip}</code></div>)) if node.at_css('thead')
          node.content = node.at_css('.code pre').content
          node.name = 'pre'
          node['data-language'] = node['class'][/(javascript|js|html|hbs|handlebars)/, 1]
          node['data-language'] = node['data-language'].sub(/(hbs|handlebars)/, 'html')
        end

        css('h1 .access').each do |node|
          node.replace(" (#{node.content})")
        end

        css('*[data-anchor]').each do |node|
          node['id'] = node['data-anchor']
          node.remove_attribute('data-anchor')
        end

        css('> h3[id]').each do |node|
          node.name = 'h2'
        end

        if subpath.end_with?('/methods') || subpath.end_with?('/properties') || subpath.end_with?('/events')
          css('.attributes ~ *').each do |node|
            break if node['class'] == 'tabbed-layout'
            node.remove
          end
        end

        css('.attributes').each do |node|
          html = node.inner_html
          html.gsub! %r{<span class="attribute-label">(.+?)</span>}, '<th>\1</th>'
          html.gsub! %r{<span class="attribute-value">(.+?)</span>}, '<td>\1</td>'
          html.gsub! %r{<div class="attribute">(.+?)</div>}, '<tr>\1</tr>'
          node.replace("<table>#{html}</table>")
        end

        css('div.attribute').each do |node|
          node.name = 'p'
        end

        css('.tabbed-layout').each do |node|
          node.before(node.at_css('.api__index__content', '.api-index-filter')).remove
        end

        css('div.ember-view', 'dl > div').each do |node|
          node.before(node.children).remove
        end

        css('section > h3').each do |node|
          node.name = 'h4' if node.previous_element
        end

        css('section').each do |node|
          node.before(node.children).remove
        end

        css('ul', 'h3', 'h4', 'a').remove_attr('class')
        css('a[id]').remove_attr('id')
      end

      def guide
        # Remove code highlighting
        css('.filename').each do |node|
          node.content = node.at_css('pre code').content
          node.name = 'pre'
          node['data-language'] = node['class'][/(javascript|js|html|hbs|handlebars)/, 1]
          node['data-language'] = node['data-language'].sub(/(hbs|handlebars)/, 'html')
        end

        if root_page?
          at_css('h1').content = 'Ember.js'
        end

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
