module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#page-content')

        css('font').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
