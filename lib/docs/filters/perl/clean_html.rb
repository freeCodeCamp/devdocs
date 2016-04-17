module Docs
  class Perl
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = '<h1>Perl 5 Documentation</h1>'
      end

      def other
        @doc = at_css('#content_body')

        css('noscript', '#recent_pages', '#from_search', '#page_index', '.mod_az_list').remove

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        at_css('h2').name = 'h1'

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
          node.content = node.content
          node.inner_html = node.inner_html.strip_heredoc
          node['data-language'] = 'perl'
        end

        if slug =~ /functions/ || slug == 'perlvar'
          css('ul > li[id]').each do |node|
            heading = node.at_css('b')
            heading.name = 'h2'
            heading['id'] = node['id']
            node.parent.before(node.children)
            node.remove
          end
        end

        doc
      end
    end
  end
end
