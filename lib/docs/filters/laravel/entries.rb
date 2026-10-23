module Docs
  class EntryIndex
    def types_as_json
      @types.values
        .sort_by { |type| natural_sort_key(type.name) }
        .map(&:as_json)
    end

    def natural_sort_key(name)
      name.downcase.scan(/\d+|\D+/).map do |part|
        part.match?(/\A\d+\z/) ? [0, part.to_i] : [1, part]
      end
    end
  end

  class Laravel
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if api_page?
          name = at_css('h1').content.strip.remove('Illuminate\\')
          name << " (#{type})" unless name.start_with?(self.type)
          name
        else
          at_css('h1').content
        end
      end

      def get_type
        if docs_page? and (version.to_i > 5 or is_version_5)
          guide_sections = css(".docs_sidebar > ul > li")
          active_link = guide_sections.at_css("li.active a")

          active_section = active_link.ancestors('li.sub--on')
          index = guide_sections.index(active_section.first)

          heading = active_section.at_css('> h2')

          return heading ? "Guides: #{index} - #{heading.content.strip}" : 'Guides'
        end

        if docs_page? and (version === "4.2")
          guide_sections = css(".docs_sidebar > ul > li")
          active_link = guide_sections.at_css("ul > li > a[href$='#{result[:path]}']")

          active_section = active_link.ancestors('li')
          index = guide_sections.index(active_section.last)

          heading = active_section.at_css('> h2')

          return heading ? "Guides: #{index} - #{heading.content.strip}" : 'Guides'
        end

        type = slug.remove(%r{api/[1-9]?\d.[0-9x]/}).remove('Illuminate/').remove(/\/\w+?\z/).gsub('/', '\\')

        if type.end_with?('Console')
          type.split('\\').first
        elsif type.start_with?('Contracts')
          'Contracts'
        elsif type.start_with?('Database')
          type.split('\\')[0..2].join('\\')
        else
          type.split('\\')[0..1].join('\\')
        end
      end

      def additional_entries
        return [] if root_page? || !api_page?
        base_name = self.name.remove(/\(.+\)/).strip

        css('h3[id^="method_"]').each_with_object [] do |node, entries|
          next if node.at_css('.location').content.start_with?('in')

          name = node['id'].remove('method_')
          name.prepend "#{base_name}::"
          name << '()'

          entries << [name, node['id']]
        end
      end

      def api_page?
        current_url.origin.start_with?('https://api.laravel.com')
      end

      def docs_page?
        current_url.origin.start_with?('https://laravel.com')
      end

      def include_default_entry?
        !subpath.end_with?('classes.html')
      end

      def is_version_5
        version.match?(/5\.[0-8]/)
      end
    end
  end
end
