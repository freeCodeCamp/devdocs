module Docs
  class Java
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('.topNav', '.subNav', '.bottomNav').remove
          title = at_css('.header > .title')
          title.content = title.content.strip
          at_css('.header').before(title)
          title.parent.remove
        else
          title = at_css('.header > .title')
          title.content = title.content.strip
          title.name = "h1"
          container = at_css('.contentContainer, .classUseContainer')
          container.child.before(title)
          @doc = container

          css('.details li.blockList > a[name]').each do |node|
            node.next_element['id'] = node['name']
          end
        end

        # Java syntax highlighter
        css('pre').each do |node|
          node['data-language'] = 'java'
        end
        doc
      end
    end
  end
end