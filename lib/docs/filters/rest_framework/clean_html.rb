module Docs
  class RestFramework
    class CleanHtmlFilter < Docs::Filter
      def call
        css('hr').remove

        css('.badges').each do |node|
          node.remove
        end

        css('pre').each do |node|
          node['data-language'] = 'python'
        end

        css('h1').each do |node|
          node['style'] = nil
        end

        # Translate source files links to DevDocs links
        links = Nokogiri::XML::Node.new('p', doc)
        links['class'] = '_links'

        css('a.github').each do |node|
          span = node.at_css('span')
          node.content = span.content
          span.remove
          node['class'] = '_links-link'
          links.add_child(node)
        end
        doc.add_child(links)

        doc
      end
    end
  end
end
