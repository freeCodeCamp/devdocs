module Docs
  class Reactivex
    class CleanHtmlFilter < Filter
      def call
        # Can't use options[:container] because then the navigation bar wouldn't be scraped
        @doc = at_css(root_page? ? '.col-md-8' : '.col-sm-8')

        # Remove breadcrumbs
        css('.breadcrumb').remove

        # Titleize title on Backpressure Operators page
        if subpath == 'documentation/operators/backpressure.html'
          title = at_css('h1')
          title.content = title.content.titleize
        end

        # Lower all h1 headers except the first one
        css('* + h1').each do |node|
          node.name = 'h2'
        end

        # Pull code blocks in links out of their <strong> parent (if possible)
        css('a > strong > code').each do |node|
          # Skip if the parent had multiple code nodes and node.parent.replace already ran for one
          next unless node.parent.name == 'strong'

          node.parent.replace node.parent.children
        end

        # Pull header out of trees
        tree = at_css('#tree')
        unless tree.nil?
          title = tree.at_css('h1')
          title.name = 'h2'
          tree.before(title)
        end

        # Beautify operator descriptions
        at_css('h3').name = 'blockquote' if subpath.include?('operators/')

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
          # Remove the link, keep the children
          link = node.at_css('a')
          link.replace(link.children) unless link.nil?

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
