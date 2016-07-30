module Docs
  class Bootstrap
    class EntriesV3Filter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        name
      end

      def additional_entries
        return [] if root_page?
        entries = []

        css('.bs-docs-sidenav > li').each do |node|
          link = node.at_css('a')
          name = link.content
          next if IGNORE_ENTRIES.include?(name)

          id = link['href'].remove('#')
          entries << [name, id]
          next if name =~ /Sass|Less|Glyphicons/

          node.css('> ul > li > a').each do |link|
            n = link.content
            next if n.start_with?('Ex: ') || n.start_with?('Default ') || n =~ /example/i || IGNORE_ENTRIES.include?(n)
            id = link['href'].remove('#')
            n.downcase!
            n.prepend "#{name}: "
            entries << [n, id]
          end
        end

        %w(modals dropdowns scrollspy tabs tooltips popovers alerts buttons collapse carousel affix).each do |dom_id|
          css("##{dom_id}-options + p + div tbody td:first-child").each do |node|
            name = node.content.strip
            id = node.parent['id'] = "#{dom_id}-#{name.parameterize}-option"
            name.prepend "#{dom_id.singularize.titleize}: "
            name << ' (option)'
            entries << [name, id]
          end

          css("##{dom_id}-methods ~ h4 code").each do |node|
            next unless name = node.content[/\('(\w+)'\)/, 1]
            id = node.parent['id'] = "#{dom_id}-#{name.parameterize}-method"
            name.prepend "#{dom_id.singularize.titleize}: "
            name << ' (method)'
            entries << [name, id]
          end
        end

        entries
      end

      IGNORE_ENTRIES = %w(
        Overview
        Introduction
        Usage
        Methods
        Options
      )
    end
  end
end
