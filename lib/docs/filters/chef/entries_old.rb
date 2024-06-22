module Docs
  class Chef
    class EntriesOldFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.body h1').content
        name.remove! "\u{00b6}"
        name.remove! 'About the '
        name.remove! 'About '
        name
      end

      CLIENT_TYPE_BY_SLUG_END_WITH = {
        'knife_common_options'               => 'Workflow Tools',
        'knife_using'                        => 'Workflow Tools',
        'resource_common'                    => 'Cookbooks',
        'config_rb_knife_optional_settings'  => 'Workflow Tools',
        'knife_index_rebuild'                => 'Workflow Tools',
        'handlers'                           => 'Extend Chef',
        'dsl_recipe'                         => 'Extend Chef',
        'resource'                           => 'Extend Chef'
      }

      SERVER_TYPE_BY_SLUG_END_WITH = {
        'auth'                               => 'Theory & Concepts',
        'install_server'                     => 'Setup & Config',
        'install_server_pre'                 => 'Setup & Config',
        'config_rb_server_optional_settings' => 'Manage the Server',
        'ctl_chef_server'                    => 'Manage the Server'
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
