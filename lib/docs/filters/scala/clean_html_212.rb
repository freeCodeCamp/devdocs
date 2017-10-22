module Docs
  class Scala
    class CleanHtml212Filter < Filter
      def call
        css('.permalink').remove

        definition = at_css('#definition')
        begin
          type_full_name = {c: 'class', t: 'trait', o: 'object', 'p': 'package'}
          type = type_full_name[definition.at_css('.big-circle').text.to_sym]
          name = definition.at_css('h1').text

          package = definition.at_css('#owner').text rescue ''
          package = package + '.' unless name.empty? || package.empty?

          other = definition.at_css('.morelinks').dup
          other_content = other ? "<h3>#{other.to_html}</h3>" : ''

          definition.replace %Q|
            <h1><small>#{type} #{package}</small>#{name}</h1>
            #{other_content}
          |

        end if definition

        doc
      end

      private

      def change_tag!(new_tag, node)
        node.replace %Q|<#{new_tag}>#{node.inner_html}</#{new_tag}>|
      end
    end
  end
end
