module Docs
  class Haskell
    class CleanHtmlFilter < Filter
      def call
        if root_page? || !result[:entries].empty?
          subpath.start_with?('users_guide') ? guide : api
          doc.inner_html = %(<div class="#{subpath.start_with?('users_guide') ? '_sphinx' : '_haskell-api'}">#{doc.inner_html}</div>)
          doc.child.before(at_css('h1'))
        end

        doc
      end

      def guide
        css('#indices-and-tables + ul', '#indices-and-tables').remove

        Docs::Sphinx::CleanHtmlFilter.new(doc, context, result).call
      end

      def api
        if root_page?
          css('#description', '#module-list').each do |node|
            node.before(node.children).remove
          end
          return doc
        end

        css('h1').each do |node|
          node.remove if node.content == 'Documentation'
        end

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        at_css('#module-header').tap do |node|
          heading = at_css('.caption')
          heading.name = 'h1'
          node.before(heading)
          node.before(node.children).remove
        end

        css('#synopsis', '.selflink').remove

        css('#interface', 'h2 code', 'span.keyword', 'div.top', 'div.doc', 'code code', '.inst-left').each do |node|
          node.before(node.children).remove
        end

        css('a[name]').each do |node|
          node['id'] = node['name']
          node.remove_attribute('name')
        end

        css('p.caption').each do |node|
          node.name = 'h4'
        end

        css('em').each do |node|
          if node.content.start_with?('O(')
            node.name = 'span'
            node['class'] = 'complexity'
          elsif node.content.start_with?('Since')
            node.name = 'span'
            node['class'] = 'version'
          end
        end

        css('pre code').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
