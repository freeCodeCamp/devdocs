module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        css('h1 .app-vsn').remove
        (at_css('h1 > span') or at_css('h1')).content.strip
      end

      def get_type
        section = at_css('h1 a.source').attr('href').match('elixir/pages/([^/]+)/')&.captures&.first
        if section == "mix-and-otp"
          return "Mix & OTP"
        elsif section
          return section.gsub("-", " ").capitalize
        end

        name = at_css('h1 span').text
        case name.split(' ').first
        when 'mix' then 'Mix Tasks'
        when 'Changelog' then 'References'
        else
          case at_css('h1 small').try(:content)
          when 'exception'
            'Exceptions'
          when 'protocol'
            'Protocols'
          else
            name
          end
        end
      end

      def additional_entries
        return [] if root_page?

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
