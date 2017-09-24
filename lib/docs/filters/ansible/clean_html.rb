module Docs
  class Ansible
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#page-content')

        css('.__cf_email__').each do |node|
          node.replace(decode_cloudflare_email(node['data-cfemail']))
        end

        doc
      end
    end
  end
end
