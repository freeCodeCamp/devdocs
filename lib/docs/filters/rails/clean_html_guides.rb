module Docs
  class Rails
    class CleanHtmlGuidesFilter < Filter
      def call
        return doc unless slug.start_with?('guides')

        at_css('#mainCol').prepend_child at_css('#feature .wrapper').children
        @doc = at_css('#mainCol')

        container = Nokogiri::XML::Node.new 'div', doc.document
        container['class'] = '_simple'
        container.children = doc.children
        doc << container

        css('h2, h3, h4, h5, h6').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end

        doc.prepend_child at_css('h1')

        css('#subCol', '.code_container').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          code = node.at_css('code')
          language = code['class']
          break if language.nil?
          language = language [/highlight ?(\w+)/, 1]
          node['data-language'] = language unless language == 'plain'
          code.remove_attribute('class')
          node.content = node.content.strip
        end

        doc
      end
    end
  end
end
