module Docs
  class Rails
    class CleanHtmlFilter < Filter
      def call

        if current_url.to_s.match?('guides')
          css('img, textarea, button, .anchorlink').remove

          at_css('#mainCol').prepend_child at_css('#feature .wrapper').children
          @doc = at_css('#mainCol')

          container = Nokogiri::XML::Node.new 'div', doc
          container['class'] = '_rails'
          container.children = doc.children
          doc << container

          css('h2, h3, h4, h5, h6').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
          end

          doc.prepend_child at_css('h1')

          if version == '6.1' || version == '6.0'
            css('pre').each do |node|
              code = node.at_css('code')
              language = code['class'][/highlight ?(\w+)/, 1]
              node['data-language'] = language unless language == 'plain'
              code.remove_attribute('class')
              node.content = node.content.strip
            end
          end

        else
          title = at_css('h2')
          title.name = 'h1'

          @doc = at_css('#content')
          @doc.prepend_child(title)

          css('table td').each do |node|
            node.remove if node.content.empty?
          end

          css('.permalink').remove

          css('.sectiontitle').each do |node|
            node.name = 'h2'
          end

          css('pre').each do |node|
            node['data-language'] = 'ruby'
          end

          # move 'source on github' to the end of the source code
          css('.sourcecode').each do |node|
            github_url = node.at_css('.github_url')
            github_url.content = "Source on Github"
            node.at_css('.source-link').content = 'Source:'
            node.at_css('.dyn-source').after(github_url)
          end
        end

        doc
      end
    end
  end
end
