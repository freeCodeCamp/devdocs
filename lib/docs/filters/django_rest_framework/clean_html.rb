module Docs
  class DjangoRestFramework
    class CleanHtmlFilter < Docs::Filter
      def call
        css('hr').remove
        css('.badges').remove

        css('pre').attr('data-language', 'python')

        css('h1').remove_attribute('style')
        css('.promo a').remove_attribute('style')

        # Translate source files links to DevDocs links
        links = Nokogiri::XML::Node.new('p', doc)
        links['class'] = '_links'

        css('a.github').each do |node|
          span = node.at_css('span')
          node.content = span.content
          node['class'] = '_links-link'
          links.add_child(node)
        end

        doc.add_child(links)

        doc
      end
    end
  end
end
