module Docs
  class Perl
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'Platform-Specific' => 'Platform Specific',
        'Internals and C Language Interface' => 'Internals',
        'Tutorials' => 'Manual: Tutorials',
        'Overview' => 'Manual: Overview'
      }

      # Individual pages within the Perl documentation are missing all context
      # for anything even resembling a 'type'. So we're going to grab it
      # elsewhere with a neat trick: dynamically generate a map from a few
      # ~index~ pages at runtime which is then referenced on future pages.
      # Prepopulate w/ edge cases
      TYPES = {
        'pod2man' => 'Utilities',
        'pod2text' => 'Utilities',
        'encguess' => 'Utilities',
        'streamzip' => 'Utilities',
        'pl2pm' => 'Utilities',

        'perl' => 'Manual: Overview',
        'perldoc' => 'Manual: Overview',
        'perlintro' => 'Manual: Overview',
        'perlop' => 'Operators',
        'perlvar' => 'Variables',
        'perlref' => 'Reference Manual',
        'modules' => 'Standard Modules',
        'perlutil' => 'Utilities',

        'warnings' => 'Pragmas',
        'strict' => 'Pragmas',

        'Pod::Text::Overstrike' => 'Standard Modules',
        'Test2::EventFacet::Hub' => 'Standard Modules'
      }

      def call
        case slug
        when 'perl'
          css('h2').each do |heading|
            heading.next_element.css('a').each do |node|
              TYPES[node.content] = heading.content
            end
          end

        when 'modules'
          node = at_css('#Pragmatic-Modules')
          node = node.next_element while node.name != 'ul'
          node.css('li').each do |n|
            TYPES[n.at_css('a').content] = 'Pragmas'
          end

          node = at_css('#Standard-Modules')
          node = node.next_element while node.name != 'ul'
          node.css('li').each do |n|
            TYPES[n.at_css('a').content] = 'Standard Modules'
          end

        when 'perlutil'
          css('dl > dt').each do |node|
            TYPES[node['id']] = "Utilities"
          end
        end

        super
      end

      def get_name
        slug
      end

      def get_type
        case slug
        when /perl.*faq/
          'Manual: FAQs'
        else
          if TYPES.key? name
            REPLACE_TYPES[TYPES[name]] || TYPES[name]
          else
            'Other'
          end
        end
      end

      def additional_entries
        case slug
        when 'perlfunc'
          css(':not(p) + dl > dt').each_with_object [] do |node, entries|
            entries << [node.content, node['id'], 'Functions']
          end
        when 'perlop'
          css('h2').each_with_object [] do |node, entries|
            entries << [node.content, node['id'], 'Operators']
          end
        when 'perlvar'
          css('> dl > dt').each_with_object [] do |node, entries|
            entries << [node.content, node['id'], 'Variables']
          end
        else
          []
        end
      end
    end
  end
end
