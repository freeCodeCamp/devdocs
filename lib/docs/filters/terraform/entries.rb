module Docs
  class Terraform
    class EntriesFilter < Docs::EntriesFilter
      # Fallback types for pages whose sidebar navigation cannot be interpreted,
      # keyed by the first segment of the slug.
      SECTION_NAME_MAP = {
        'cdktf'      => 'CDK for Terraform',
        'cli'        => 'Terraform CLI',
        'docs'       => 'Documentation',
        'intro'      => 'Intro to Terraform',
        'internals'  => 'Internals',
        'language'   => 'Configuration Language',
        'mcp-server' => 'MCP Server',
        'migrate'    => 'Migrate',
        'plugin'     => 'Plugin Development',
        'policy'     => 'Policy Enforcement',
        'registry'   => 'Registry Publishing',
        'tutorials'  => 'Tutorials',
      }

      def get_name
        at_css('#main h1').content.strip
      end

      def get_type
        # The sidebar heading names the section the page belongs to, e.g. "Terraform CLI".
        section = at_css('#sidebar-label').try(:content).try(:strip)
        root = slug.split('/').first
        section = SECTION_NAME_MAP[root] if section.blank?
        return 'Terraform' if section.blank?

        # Tutorials reuse the same section names as the reference docs
        # (e.g. "CLI"), so keep the two apart.
        return "Tutorials: #{section}" if root == 'tutorials' && section != 'Tutorials'

        group = sidebar_group
        group.present? ? "#{section}: #{group}" : section
      end

      private

      # Returns the label of the outermost collapsible group containing the
      # current page in the sidebar, e.g. "Provisioning Infrastructure".
      def sidebar_group
        nav = at_css('#sidebar-nav')
        return if nav.nil?

        node = nav.at_css('a[aria-current="page"]')
        label = nil

        while node && node != nav
          node = node.parent
          next unless node && node.name == 'li'
          button = node.at_css('> button > span')
          label = button.content.strip if button
        end

        label
      end
    end
  end
end
