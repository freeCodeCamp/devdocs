module Docs
  class Codeigniter
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').remove

        css('h1', 'h2', 'h3', 'h4', 'h5', 'pre').each do |node|
          node.content = node.content
        end

        css('table').each do |node|
          node.remove_attribute 'border'
        end

        css('.section > h2', '.section > h3', '.section > h4', '.section > h5').each do |node|
          node['id'] = node.parent['id']
          node.parent.remove_attribute 'id'
        end

        doc.children
      end
    end
  end
end
