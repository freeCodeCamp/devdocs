module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        css('h1 .app-vsn').remove
        name = (at_css('h1 > span') or at_css('h1')).content.strip

        if current_url.path.start_with?('/getting-started')
          name.remove(/\.\z/)
        else
          name = name.split(' ').first unless name.start_with?('mix ') # ecto
          name
        end
      end

      def get_type
        if current_url.path.start_with?('/getting-started')
          if subpath.start_with?('mix-otp')
            'Guide: Mix & OTP'
          elsif subpath.start_with?('meta')
            'Guide: Metaprogramming'
          else
            'Guide'
          end
        else
          case at_css('h1 small').try(:content)
          when 'exception'
            'Exceptions'
          when 'protocol'
            'Protocols'
          else
            if name.start_with?('Phoenix')
              name.split('.')[0..2].join('.')
            elsif name.start_with?('mix ')
              'Mix Tasks'
            else
              name.split('.').first
            end
          end
        end
      end

      def additional_entries
        return [] if type == 'Exceptions' || type == 'Guide' || root_page?

        css('.detail-header').map do |node|
          id = node['id']
          # ignore text of children, i.e. source link
          name = node.children.select(&:text?).map(&:content).join.strip

          name.remove! %r{\(.*\)}
          name.remove! 'left '
          name.remove! ' right'
          name.sub! 'sigil_', '~'

          if self.name && !self.name.start_with?('Kernel')
            name.prepend "#{self.name}."
          end

          if id =~ %r{/\d+\z}
            arity = id.split('/').last
            name << " (#{arity})"
          end

          [name, id]
        end
      end

      def include_default_entry?
        !slug.end_with?('api-reference')
      end
    end
  end
end
