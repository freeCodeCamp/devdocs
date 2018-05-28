module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#page-content')

        doc
      end
    end
  end
end
