module Docs
  class Perl
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'Platform specific' => 'Platform Specific',
        'Internals and C language interface' => 'Internals',

        'perlop' => 'Operators',
        'perlvar' => 'Variables',
        'Functions' => 'Functions'
      }

      MANUAL_TYPES = %w(Overview Tutorials FAQs)

      def breadcrumbs
        @breadcrumbs ||= at_css('#breadcrumbs').content.split('>').each { |s| s.strip! }
      end

      def include_default_entry?
        slug !~ /\Aindex/
      end

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        case breadcrumbs[1]
        when 'Language reference'
          REPLACE_TYPES[breadcrumbs[2]] || 'Language'
        when /\ACore modules/
          'Core Modules'
        else
          type = REPLACE_TYPES[breadcrumbs[1]] || breadcrumbs[1]
          type.prepend 'Manual: ' if MANUAL_TYPES.include?(type)
          type
        end
      end

      def additional_entries
        case slug
        when 'perlop'
          css('h2').map do |node|
            name = node.content
            id = node.previous_element['name']
            [name, id]
          end
        when 'perlvar'
          css('#content_body > ul > li > b').map do |node|
            name = node.content
            id = node.previous_element['name']
            [name, id]
          end
        else
          []
        end
      end
    end
  end
end
