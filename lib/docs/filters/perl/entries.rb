module Docs
  class Perl
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'Platform specific' => 'Platform Specific',
        'Internals and C language interface' => 'Internals',

        'perlop' => 'Perl Operators',
        'perlvar' => 'Perl Variables',
        'Functions' => 'Functions'
      }

      def breadcrumbs
        at_css('#breadcrumbs').content.split('>').each { |s| s.strip! }
      end

      def include_default_entry?
        not slug =~ /\Aindex/ and
        not slug =~ /perlop\z/ and
        not slug =~ /perlvar/
      end

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        case breadcrumbs[1]
          when 'Language reference'
            REPLACE_TYPES[breadcrumbs[2]] || 'Language Reference'
          when /\ACore modules/
            'Core Modules'
          else
            REPLACE_TYPES[breadcrumbs[1]] || breadcrumbs[1]
        end
      end

      def additional_entries
        entries = []
        case slug
          when /perlop\z/
            css('h2').each do |node|
              name = node.content
              id = node.previous_element['name']
              entries << [name, id, get_type]
            end

          when /perlvar/
            css('#content_body > ul > li > b').each do |node|
              node['class'] = 'perlvar'
              name = node.content
              id = node.previous_element['name']
              entries << [name, id, get_type]
            end

          when /functions/
            css('#content_body > ul > li > b').each do |node|
              node['class'] = 'perlfunction'
            end

        end

        entries
      end
    end
  end
end
