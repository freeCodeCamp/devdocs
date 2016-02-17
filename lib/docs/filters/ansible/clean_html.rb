module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        # Remove 'Permalink to this headline'
        css('.headerlink').remove
        # Make proper table headers
        css('th.head').each do |node|
          node.name = 'th'
        end
        css('table').each do |node|
          node.remove_attribute('border')
          node.remove_attribute('cellpadding')
        end
        doc
      end
    end
  end
end
