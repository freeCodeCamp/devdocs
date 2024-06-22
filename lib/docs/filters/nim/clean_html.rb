module Docs
  class Nim
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#documentId .container')

        # add id to each proc, template and macro
        css('dl > dt > pre').each do |node|
          next if !(node.at_css('a'))
          node.remove_attribute('id')
          nodeId = node.at_css('a')['href']
          nodeId.gsub!(/.*\#/, '')
          node['id'] = nodeId
        end

        css('.docinfo', '.footer', 'blockquote > p:empty').remove

        css('h1:not(.title), h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        if content = at_css('#content')
          content.prepend_child at_css('h1.title')
          @doc = content
        end

        css('h1 > a', 'h2 > a', 'h3 > a', 'h4 > a').each do |node|
          node.parent['id'] = node['id'] if node['id']
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'nim' unless node.content =~ /\A[\w\-\_\:\=\ ]+\z/
        end

        css('tt').each do |node|
          node.name = 'code'
        end

        css('cite').each do |node|
          node.name = 'em'
        end

        css('.section').each do |node|
          node.first_element_child['id'] = node['id'] if node['id']
          node.before(node.children).remove
        end

        css('span.pre').each do |node|
          node.before(node.children).remove
        end

        css('blockquote > pre:only-child', 'blockquote > dl:only-child', 'blockquote > table').each do |node|
          node.parent.before(node.parent.children).remove
        end

        css('a', 'dl', 'table', 'code').remove_attr('class')
        css('table').remove_attr('border')

        doc
      end
    end
  end
end
