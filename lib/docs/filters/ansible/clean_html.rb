module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('[itemprop=articleBody]')

        css('font').each do |node|
          node.before(node.children).remove
        end

        css('.documentation-table').each do |node|
          node.css('[style]').each do |subnode|
            subnode.remove_attribute('style')
          end
        end

        doc

      end
    end
  end
end
