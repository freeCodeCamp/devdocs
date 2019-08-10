module Docs
  class Npm
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('api') && at_css('pre').content =~ /\A\s*npm\.([\w\-]+\.)*[\w\-]+/
          name = $&.strip
        else
          name = at_css('nav > section.active a.active').content
        end

        name << ' (CLI)' if slug.start_with?('cli')
        name
      end

      def get_type
        case slug
        when 'files/package.json'
          'package.json'
        when 'misc/config'
          'Config'
        else
          at_css('nav > section.active > h2').content
        end
      end

      def additional_entries
        case slug
        when 'files/package.json'
          css('#page > h2').each_with_object [] do |node, entries|
            next if node.content =~ /\A[A-Z]/
            entries << ["package.json: #{node.content}", node.at_css('.anchor')['id']]
          end
        when 'misc/config'
          css('h2:contains("Config Settings") ~ h3').map do |node|
            ["config: #{node.content}", node.at_css('.anchor')['id']]
          end
        else
          []
        end
      end
    end
  end
end
