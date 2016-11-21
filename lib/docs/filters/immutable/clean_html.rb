module Docs
  class Immutable
    class CleanHtmlFilter < Filter
      def call
        css('section', 'span', 'div[data-reactid]').each do |node|
          node.before(node.children).remove
        end

        css('.codeBlock').each do |node|
          node.name = 'pre'
          node.content = node.content
          node['data-language'] = 'js'
        end

        css('*[data-reactid]').remove_attr('data-reactid')
        css('a[target]').remove_attr('target')

        css('a[href^="#"]').each do |node|
          node['href'] = node['href'].sub(/\A#\//, '#').gsub('/', '.').downcase
        end

        type = type_id = nil
        css('*').each do |node|
          if node.name == 'h1'
            node['id'] = type_id = node.content.strip.downcase
            type = node.content.strip
          elsif node.name == 'h3'
            node['id'] = node.content.strip.downcase
            node['id'] = node['id'].remove('()') unless node['id'] == "#{type_id}()"

            unless node['id'].start_with?(type_id)
              node.content = "#{type}##{node.content}"
              node['id'] = "#{type_id}.#{node['id']}" unless node['id'].start_with?("#{type_id}.")
            end
          end
        end

        css('h4.groupTitle').each do |node|
          node.name = 'h2'
        end

        css('*[class]').remove_attr('class')

        doc
      end
    end
  end
end
