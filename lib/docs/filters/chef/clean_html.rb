module Docs
  class Chef
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#main-content-col')

        if root_page?
          css('img').remove
        end

        css('pre').each do |node|
          node.remove_attribute('style')

          if !(node.classes.include?('highlight'))
            node.add_class('highlight')
            node['data-language'] = 'ruby'
          end
        end

        css('#feedback').remove

        css('.mini-toc-header', '.TOC-button').remove

        doc
      end
    end
  end
end
