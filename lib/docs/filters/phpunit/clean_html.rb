module Docs
  class Phpunit
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = <<-HTML
          <p>PHPUnit is a programmer-oriented testing framework for PHP.<br>
          It is an instance of the xUnit architecture for unit testing frameworks.</p>
        HTML
      end

      def other
        # set root on appendix
        @doc = doc.at_css('div.appendix')

        # remove attributes 'style'
        css('*').remove_attr('style')

        # clean titles
        css('div.titlepage').each do |node|
          title = node.at_css('.title')
          case title.name
          when 'h1'
            # remove 'Appendix X.' from top title
            nodetitle = title.content
            title.content = nodetitle.gsub(/Appendix \w+\. /, '')
          when 'h2'
            # set link anchors in entries (title level 2)
            anchor = Nokogiri::XML::Node.new "a", @doc
            anchor.content = title.content
            anchor['id'] = title.content.downcase.gsub(/[^a-z]/, '')
            title.content = ''
            anchor.parent = title
          end
          node.replace title
        end

        # set anchor for internal references
        css('p.title').each do |node|
          anchor = Nokogiri::XML::Node.new "a", @doc
          anchor.content = node.content
          anchor['id'] = anchor.content[/\w+ [A-z0-9.]+/].downcase.parameterize
          node.content = ''
          anchor.parent = node
        end

        # clean internal references
        css('a').each do |node|
          page = node['href'][/([A-z.-]+)?#/, 1] if node['href']
          if page then
            page  = page + '.html' unless page[/.*\.html/]
            if Phpunit.initial_paths.include? page
              node['href'] = node['href'].gsub(/#[A-z.-]+/, '#' + node.content.downcase.parameterize)
            end
          end
        end

      end
    end
  end
end
