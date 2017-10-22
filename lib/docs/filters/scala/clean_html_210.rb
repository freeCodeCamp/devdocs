module Docs
  class Scala
    class CleanHtml210Filter < Filter
      def call
        definition = at_css('#definition')
        begin
          type = definition.at_css('.img_kind').text
          name = definition.at_css('h1').text.strip

          package = definition.at_css('#owner').text rescue ''
          package = package + '.' unless name.empty? || name.start_with?('root')

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
