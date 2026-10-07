module Docs
  class Drizzle
    class EntriesFilter < Docs::EntriesFilter
      NAMES = {
        'kit-overview' => 'Drizzle Kit',
        'perf-queries' => 'Query performance',
        'perf-serverless' => 'Serverless performance',
        'query-utils' => 'Query utils',
        'relations-schema-declaration' => 'Relations fundamentals',
        'rqb' => 'Relational queries',
        'rqb-v2' => 'Relational queries',
        'seed-functions' => 'Seed generators',
        'seed-overview' => 'Drizzle Seed',
        'seed-versioning' => 'Seed versioning',
        'sql-schema-declaration' => 'Schema declaration',
        'upgrade-v1' => 'Upgrading to v1'
      }

      # Pages whose sections each document one API
      API_TYPES = {
        'column-types' => 'Data types',
        'operators' => 'Filters',
        'seed-functions' => 'Seed generators'
      }

      NO_ADDITIONAL_ENTRIES_TYPES = ['Connect', 'Upgrade to v1.0']

      NOISE_SECTION = /\A(?:Install(?:ation| the dependencies)?|Usage|Example|Extended example|Extended list of (?:available )?configurations|Multiple configuration files in one project|\w+ connection docs)\z/i

      def get_name
        label = nav_label
        # SingleStore keeps the APIs superseded in v1 as "[OLD] ..." pages
        legacy = label.delete_prefix!('[OLD] ')
        name = NAMES[slug] || label
        name = "drizzle-kit #{name}" if slug.start_with?('drizzle-kit-')
        legacy ? "#{name} (legacy)" : name
      end

      def get_type
        return 'Other' unless nav_item
        section = nav_item.xpath('preceding-sibling::div[contains(@class, "nav-separator")][1]').first
        section.content.strip.delete_suffix(' RC').sub(/\Ameet drizzle\z/, 'Meet Drizzle')
      end

      def additional_entries
        return [] if root_page? || NO_ADDITIONAL_ENTRIES_TYPES.include?(type)

        nodes = content.css('h2[id], h3[id]').to_a
        api_nodes = slug == 'column-types' ? api_column_types(nodes) : nodes

        nodes.each_with_object([]) do |node, entries|
          heading = heading_text(node)
          next if heading.empty? || heading == '---' || heading =~ NOISE_SECTION

          if (api_type = API_TYPES[slug]) && api_nodes.include?(node)
            heading = "funcs.#{heading}()" if slug == 'seed-functions'
            entries << [heading, node['id'], api_type]
          elsif heading.start_with?('sql`', 'sql<', 'sql.')
            entries << [heading, node['id']]
          else
            entries << ["#{name}: #{heading}", node['id']]
          end
        end
      end

      private

      def content
        at_css('.documentation-content')
      end

      def nav_item
        @nav_item ||= at_css('.nav-items .nav-item--active')
      end

      def nav_label
        (nav_item || content.at_css('h1')).content.strip
      end

      # Column options follow the data types, after the last separator
      def api_column_types(nodes)
        last_separator = nodes.rindex { |node| heading_text(node) == '---' }
        last_separator ? nodes[0...last_separator] : nodes
      end

      # The site typesets sql`` as sql“
      def heading_text(node)
        node.content.strip.sub(/\Asql“/, 'sql``').delete_suffix(':')
      end
    end
  end
end
