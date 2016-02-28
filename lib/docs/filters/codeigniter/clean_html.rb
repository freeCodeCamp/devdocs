module Docs
  class Codeigniter
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').remove

        css('h1', 'h2', 'h3', 'h4', 'h5', 'pre').each do |node|
          node.content = node.content
        end

        css('div[class^="highlight-"]').each do |node|
          node.content = node.content.strip
          node.name = 'pre'
          node['class'] = 'php' if node['class'].include?('highlight-ci')
        end

        css('table').each do |node|
          node.remove_attribute 'border'
        end

        css('.section').each do |node|
          node.first_element_child['id'] = node['id'] if node['id']
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
