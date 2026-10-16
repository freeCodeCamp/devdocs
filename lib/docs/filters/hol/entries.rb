module Docs
  class Hol
    class EntriesFilter < Docs::EntriesFilter
      def include_default_entry?
        !root_page?
      end

      def get_name
        heading = at_css('h1')
        return super if heading.nil?
        normalized_heading_text(heading)
      end

      def get_type
        return standards_sdk_type if standards_sdk_doc?
        return registry_broker_type if registry_broker_doc?
        nil
      end

      def additional_entries
        return [] if root_page?

        css('h2[id], h3[id]').each_with_object([]) do |node, entries|
          section_name = normalized_heading_text(node)
          next if section_name.empty?
          next if section_name == name
          entries << ["#{name}: #{section_name}", node['id']]
        end
      end

      private

      def normalized_heading_text(node)
        fragment = node.dup
        fragment.css('a').remove
        fragment.content.gsub(/\s+/, ' ').strip
      end

      def standards_sdk_doc?
        slug.start_with?('libraries/standards-sdk/')
      end

      def registry_broker_doc?
        slug.start_with?('registry-broker/')
      end

      def standards_sdk_type
        sdk_slug = slug.delete_prefix('libraries/standards-sdk/').split('/').first
        return 'Standards SDK' if sdk_slug.nil? || sdk_slug.empty?
        return sdk_slug.upcase if sdk_slug.match?(/\Ahcs-\d+\z/)

        case sdk_slug
        when 'registry-broker-client'
          'SDK Registry Broker Client'
        when 'utils-services'
          'SDK Utilities & Services'
        else
          "SDK #{sdk_slug.tr('-', ' ').split.map(&:capitalize).join(' ')}"
        end
      end

      def registry_broker_type
        broker_slug = slug.delete_prefix('registry-broker/').split('/').first
        return 'Registry Broker' if broker_slug.nil? || broker_slug.empty?

        case broker_slug
        when 'api'
          'Registry Broker API'
        when 'chat', 'encrypted-chat', 'multi-protocol-chat'
          'Registry Broker Chat'
        else
          "Registry Broker #{broker_slug.tr('-', ' ').split.map(&:capitalize).join(' ')}"
        end
      end
    end
  end
end
