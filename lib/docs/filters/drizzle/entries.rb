module Docs
  class Drizzle
    class EntriesFilter < Docs::EntriesFilter
      # Sidebar labels that are too vague once out of their sidebar section
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

      # Pages documenting one API per section (a column type, a filter operator,
      # ...), whose sections are indexed under their own name and type
      API_TYPES = {
        'column-types' => 'Data types',
        'operators' => 'Filters',
        'seed-functions' => 'Seed generators'
      }

      # The sidebar sections whose pages' sections aren't worth indexing: the
      # drivers' setup steps and the upgrade guides
      NO_ADDITIONAL_ENTRIES_TYPES = ['Connect', 'Upgrade to v1.0']

      # Sections every page of a kind has, which say nothing on their own
      NOISE_SECTION = /\A(?:Install(?:ation| the dependencies)?|Usage|Example|Extended example|Extended list of (?:available )?configurations|Multiple configuration files in one project|\w+ connection docs)\z/i

      def get_name
        label = nav_label
        # The SingleStore documentation keeps the pages of the APIs superseded
        # in v1 alongside their replacement, labeled "[OLD] ..."
        legacy = label.delete_prefix!('[OLD] ')

        name = NAMES[slug] || label
        # The drizzle-kit commands are labeled with the command alone
        name = "drizzle-kit #{name}" if slug.start_with?('drizzle-kit-')
        legacy ? "#{name} (legacy)" : name
      end

      # The sidebar section, e.g. "Manage schema"
      def get_type
        return 'Other' unless nav_item
        section = nav_item.xpath('preceding-sibling::div[contains(@class, "nav-separator")][1]').first
        # Some dialects label the upgrade guides' section "Upgrade to v1.0 RC"
        section.content.strip.delete_suffix(' RC').sub(/\Ameet drizzle\z/, 'Meet Drizzle')
      end

      def additional_entries
        return [] if root_page? || NO_ADDITIONAL_ENTRIES_TYPES.include?(type)

        content.css('h2[id], h3[id]').each_with_object([]) do |node, entries|
          heading = heading_text(node)
          next if heading.empty? || heading == '---' || heading =~ NOISE_SECTION

          if (api_type = API_TYPES[slug])
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

      # The page's link in the sidebar
      def nav_item
        @nav_item ||= at_css('.nav-items .nav-item--active')
      end

      def nav_label
        (nav_item || content.at_css('h1')).content.strip
      end

      # The template tag's backticks are typeset as a quotation mark (sql“)
      def heading_text(node)
        node.content.strip.sub(/\Asql“/, 'sql``').delete_suffix(':')
      end
    end
  end
end
