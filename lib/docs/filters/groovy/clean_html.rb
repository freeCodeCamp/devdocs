module Docs
  class Groovy
    class CleanHtmlFilter < Filter
      def new_node(content)
        node = Nokogiri::XML::Node.new 'h1', doc
        node.content = content
        node
      end

      def call
        title = at_css('.title').content
        @doc = at_css('.contentContainer')
        doc.child.before new_node(title)

        if root_page?
          css('tr > td > a').each do |node|
            node.parent.content = node.content
          end
        end

        css('.subNav', '.bottomNav').remove

        css('hr + br', 'p + br', 'div + br', 'hr').remove

        css('table').each do |node|
          node.remove_attribute 'summary'
          node.remove_attribute 'cellspacing'
          node.remove_attribute 'cellpadding'
          node.remove_attribute 'border'
        end

        # Move anchor name/id to heading tag
        css('a[name] + h3').each do |node|
          node['id'] = node.previous_element['name']
        end

        css('a[name] + ul.blockListLast').each do |node|
          node.at_css('li > h4')['id'] = node.previous_element['name']
        end

        # Tag constructors, methods, and elements before removing context tags
        css('#constructor_detail').each do |node|
          node.parent.css('h4').each do |n|
            n['class'] = 'constructor'
          end
        end

        css('#method_detail').each do |node|
          node.parent.css('h4').each do |n|
            n['class'] = 'method'
          end
        end

        css('#element_detail').each do |node|
          node.parent.css('h4').each do |n|
            n['class'] = 'element'
          end
        end

        css('#field_detail').each do |node|
          node.parent.css('h4').each do |n|
            n['class'] = 'field'
          end
        end

        css('#enum_constant_detail').each do |node|
          node.parent.css('h4').each do |n|
            n['class'] = 'enum_constant'
          end
        end

        # Flatten and remove unnecessary intermediate tags
        css('ul.blockList > li.blockList', 'ul.blockListLast > li.blockList').each do |node|
          node.before(node.children).remove
        end

        css('ul.blockList', 'ul.blockListLast').each do |node|
          node.before(node.children).remove
        end

        css('ul.blockList > table').each do |node|
          node.parent.before(node).remove
        end

        css('h3', 'h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end

        css('pre').each do |node|
          node['data-language'] = 'groovy'
        end

        doc
      end
    end
  end
end
