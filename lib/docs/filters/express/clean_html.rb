module Docs
  class Express
    class CleanHtmlFilter < Filter
      def call
        i = 1
        n = at_css("#navmenu a[href='#{result[:path].split('/').last}']").parent
        i += 1 while n && n = n.previous_element
        at_css('h1')['data-level'] = i

        @doc = at_css('#api-doc, .content')

        css('section', 'div.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        @doc = at_css('#page-doc') unless root_page?

        if root_page?
          at_css('h1').remove
          css('> header', '#menu').remove
        end

        # Put id attributes on headings
        css('h2 + a[name]').each do |node|
          node.previous_element['id'] = node['name']
          node.remove
        end

        css('table[border]').each do |node|
          node.remove_attribute 'border'
        end

        # Remove code highlighting
        css('figure.highlight').each do |node|
          node['data-language'] = node.at_css('code[data-lang]')['data-lang']
          node.content = node.content
          node.name = 'pre'
        end

        css('pre > code').each do |node|
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
          node.parent.content = node.parent.content
        end

        # Fix links to the method reference
        css('a').each do |node|
          node['href'] = node['href'].sub('4x/api', 'index')
        end

        doc
      end
    end
  end
end
