module Docs
  class Maxcdn
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = id_prefix = nil

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
            type.remove! %r{ API\z}
            type.remove! ' Custom Domains'
            id_prefix = type.parameterize
            type = 'Reports' if type.starts_with? 'Reports'
          elsif node.name == 'h3'
            next unless type
            name = node.content.strip
            id = "#{id_prefix}-#{name}".parameterize
            node['id'] = id

            if name.ends_with?('Domain') && ['Push Zone', 'Pull Zone', 'VOD Zone'].include?(type)
              name << " (#{type})"
            end

            entries << [name, id, type]
          end
        end
      end
    end
  end
end
