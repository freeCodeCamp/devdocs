module Docs
  class Perl
    class CleanHtmlFilter < Filter
      REMOVE_LIST = %w(
        noscript
        #recent_pages
        #from_search
        #page_index
        .mod_az_list
      )

      def call
        root_page? ? root : other
      end

      def root
        doc.inner_html = '<h1>Perl 5 Documentation</h1>'
      end

      def other
        @doc = at_css('#content_body')

        css(*REMOVE_LIST).remove

        css('h4').each { |node| node.name = 'h5' }
        css('h3').each { |node| node.name = 'h4' }
        css('h2').each { |node| node.name = 'h3' }
        css('h1').drop(1).each { |node| node.name = 'h2' }

        css('a[name] + h2', 'a[name] + h3', 'a[name] + h4', 'a[name] + h5').each do |node|
          node['id'] = node.previous_element['name']
        end

        css('li > a[name]').each do |node|
          node.parent['id'] = node['name']
        end

        css('pre').each do |node|
          node.css('li').each do |li|
            li.content = li.content + "\n"
          end
          node.content =  node.content
        end

        doc
      end
    end
  end
end
