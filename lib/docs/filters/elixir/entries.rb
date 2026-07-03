module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        css('h1 .app-vsn').remove
        (at_css('h1 > span') or at_css('h1')).content.strip
      end

      def get_type
        # Use section titles for Elixir docs
        section = at_css('.top-heading a.source')&.attr('href')&.match('elixir/pages/([^/]+)/')&.captures&.first
        if section == "mix-and-otp"
          return "Mix & OTP"
        elsif section
        return section.gsub(/[-_]/, " ").capitalize
        end

        # Use section titles for guides
        guide = at_css('.top-heading a.source')&.attr('href')&.match('guides/(?:([^/]+)/)?')
        if guide
          section = guide.captures.first || "Guides"
          return section.gsub(/[-_]/, " ").capitalize
        end

        # Sometimes the heading includes additional text in a <small> tag,
        # in which case the main text is wrapped in a <span>
        # e.g. https://elixir.hexdocs.pm/Exception.html
        heading = at_css('.top-heading h1 span') || at_css('.top-heading h1')
        name = heading.text
        case name.split(' ').first
        when 'mix' then 'Mix Tasks'
        when 'Changelog' then 'References'
        else
          case at_css('.top-heading h1 small').try(:content)
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
