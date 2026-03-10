module Docs
  class Couchdb
    class EntriesFilter < Docs::EntriesFilter
      SLUG_MAP = {
        'api' => 'API',
        'json' => 'JSON Structures',
        'cluster' => 'Cluster Management',
        'replication' => 'Replication',
        'maintenance' => 'Maintenance',
        'partitioned' => 'Partitioned Databases'
      }

      def get_name
        at_css('h1').content.gsub(/\P{ASCII}/, '').split('.').last
      end

      def get_type
        if slug.start_with?('ddocs/views')
          'Views'
        elsif slug.start_with?('ddocs')
          'Design Documents'
        else
          SLUG_MAP[slug[/^(.+?)[-\/]/, 1]] || name
        end
      end

      def additional_entries
        needs_breakup = [
          'JSON Structure Reference',
          'Design Documents',
          'Partitioned Databases'
        ]

        if needs_breakup.include?(name)
          entries = []

          css('section > section').each do |node|
            h2 = node.at_css('h2')

            if h2.present?
              name = node.at_css('h2').content.split('.').last
              entries << [name, node['id']]
            end
          end

          entries
        else
          []
        end
      end
    end
  end
end
