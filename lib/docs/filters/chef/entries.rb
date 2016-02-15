module Docs
  class Chef
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.body h1').content
        name.remove! "\u{00b6}"
        name.remove! 'About the '
        name.remove! 'About '
        name
      end

      CLIENT_TYPE_BY_SLUG_END_WITH = {
        'knife_common_options'               => 'Knife Commands',
        'knife_using'                        => 'Knife Commands',
        'resource_common'                    => 'Chef Resources',
        'config_rb_knife_optional_settings'  => 'Config Files'
      }

      SERVER_TYPE_BY_SLUG_END_WITH = {
        'auth'                               => 'Theory & Concepts',
        'install_server_pre'                 => 'Setup & Config',
        'config_rb_server_optional_settings' => 'Config Files'
      }

      def get_type
        if server_page?
          SERVER_TYPE_BY_SLUG_END_WITH.each do |key, value|
            return "Chef Server / #{value}" if slug.end_with?(key)
          end
        else
          CLIENT_TYPE_BY_SLUG_END_WITH.each do |key, value|
            return value if slug.end_with?(key)
          end
        end

        path = nav_path
        path.delete('Reference')
        path = path[0..0]
        path.unshift('Chef Server') if server_page?

        type = path.join(' / ')
        type.sub 'Cookbooks / Cookbook', 'Cookbooks /'
        type
      end

      def server_page?
        slug.start_with?(context[:server_path])
      end

      def nav_path
        node = at_css(".nav-docs a[href='#{result[:path].split('/').last}']")
        path = []
        until node['class'] && node['class'].include?('main-item')
          path.unshift(node.first_element_child.content.strip) if node['class'] && node['class'].include?('has-sub-items')
          node = node.parent
        end
        path.unshift(node.first_element_child.content.strip)
        path
      end
    end
  end
end
