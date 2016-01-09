module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.split(' ').first.strip
      end

      def get_type
        case at_css('h1 small').try(:content)
        when 'exception'
          'Exceptions'
        when 'protocol'
          'Protocols'
        else
          if name.start_with?('Phoenix')
            name.split('.')[0..2].join('.')
          else
            name.split('.').first
          end
        end
      end

      def additional_entries
        return [] if type == 'Exceptions'

        css('.detail-header .signature').map do |node|
          id = node.parent['id']
          name = node.content.strip
          name.remove! %r{\(.*\)}
          name.remove! 'left '
          name.remove! ' right'
          name.sub! 'sigil_', '~'

          unless node.parent['class'].end_with?('macro') || self.name.start_with?('Kernel')
            name.prepend "#{self.name}."
          end

          name << " (#{id.split('/').last})" if id =~ /\/\d+\z/

          [name, id]
        end
      end

      def include_default_entry?
        !slug.end_with?('api-reference')
      end
    end
  end
end
