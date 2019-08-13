module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! ' and ', ' & '
        name
      end

      def get_type
        return 'Declaration Files' if subpath.include?('declaration-files')
        return 'Project Configuration' if slug == 'handbook/configuring-watch'
        type = at_css('#main-nav a.active').ancestors('.panel').first.at_css('> a').content
        type = name if type == 'Handbook'
        type
      end

      SKIP_ENTRIES = ['Introduction', 'A note', 'A Note', ', and', 'Techniques', ' Concepts', 'Hello World', 'Working with', 'Our ', 'Implementing ', 'Difference between', 'Basic', 'sample', 'Questions', 'Example', 'Export as close', 'Red Flags', 'First steps', 'Pitfalls', 'Well-known', 'Starting out', 'Comparing ', 'Do not', 'Trade-off', ' vs', 'Overview', 'Related']

      def additional_entries
        return [] unless slug.start_with?('handbook')
        return [] if slug.include?('release-notes')
        return [] if slug == 'handbook/writing-definition-files'

        css('.post-content h1, .post-content h2').each_with_object [] do |node, entries|
          next if node.next_element.try(:name) == 'h2'
          name = node.content.strip
          next if name.length > 40
          next if name == self.name || SKIP_ENTRIES.any? { |str| name.include?(str) }
          name.remove! %r{\A#{self.name.remove(/s\z/)}s? }
          name.sub! 'for..of', 'for...of'
          name.remove! 'Symbol.'
          name.remove! '/// '
          name.prepend "#{self.name}: "
          entries << [name, node['id']]
        end
      end
    end
  end
end
