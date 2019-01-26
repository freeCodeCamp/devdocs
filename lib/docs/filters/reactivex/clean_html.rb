module Docs
  class Reactivex
    class CleanHtmlFilter < Filter
      def call
        # Can't use options[:container] because then the navigation bar wouldn't be scraped
        @doc = at_css(root_page? ? '.col-md-8' : '.col-sm-8')

        # Remove breadcrumbs
        css('.breadcrumb').remove

        # Replace interactive demo's with links to them
        css('rx-marbles').each do |node|
          node.name = 'a'
          node.content = 'Open interactive diagram on rxmarbles.com'
          node['href'] = "https://rxmarbles.com/##{node['key']}"
          node.remove_attribute('key')
        end

        # Syntax-highlighted code blocks
        css('.code').each do |node|
          language = node['class'].gsub('code', '').strip

          pre = node.at_css('pre')
          pre['data-language'] = language
          pre.content = pre.content.strip

          node.replace(pre)
        end

        # Assume JavaScript syntax for code blocks not surrounded by a div.code
        css('pre').each do |node|
          next if node['data-language']

          node.content = node.content.strip
          node['data-language'] = 'javascript'
        end

        # Make language specific implementation titles prettier
        css('.panel-title').each do |node|
          # Remove the link, keep the text
          node.content = node.content

          # Transform it into a header for better styling
          node.name = 'h3'
        end

        # Remove language specific implementations that are TBD
        css('span').each do |node|
          next unless node.content == 'TBD'
          node.xpath('./ancestor::div[contains(@class, "panel-default")][1]').remove
        end

        # Remove the : at the end of "Language-Specific Information:"
        css('h2').each do |node|
          node.inner_html = node.inner_html.gsub('Information:', 'Information')
        end

        # Remove attributes to reduce file size
        css('div').remove_attr('class')

        doc
      end
    end
  end
end
