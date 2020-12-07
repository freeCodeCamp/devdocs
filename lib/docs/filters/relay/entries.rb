module Docs
  class Relay
    class EntriesFilter < Docs::EntriesFilter
      ONLY_SECTIONS = ['API Reference', 'Principles & Architecture']
      ONLY_SLUGS = []

      def call
        if root_page?
          css('.navGroup > h3').each do |node|
            next if not ONLY_SECTIONS.include? node.content
            node.next_element.css('a').each do |anchor|
              ONLY_SLUGS << anchor['href'].split('/').last.strip
            end
          end
        end
        super
      end

      def get_name
        at_css('h1').content
      end

      def get_type
        at_css('h1').content
      end

      def include_default_entry?
        ONLY_SLUGS.include? slug
      end

      def additional_entries
        return [] if not include_default_entry?

        css('article h2, article h3').each_with_object [] do |node, entries|
          next if node.content.include?('Argument') ||
                  node.content.starts_with?('Example')

          name = node.content
          if name.include?('(')
            name = name.match(/.*\(/)[0] + ')'
          end
          id = node.at_css('a.anchor')['id']
          entries << [name, id]
        end
      end

    end
  end
end
