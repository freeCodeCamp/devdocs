module Docs
  class Django
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.remove("\u{00b6}")
      end

      def get_type
        case subpath
        when /\Atopics/
          'Guides'
        when /\Aintro/
          'Guides: Intro'
        when /\Ahowto/
          'Guides: How-tos'
        when /\Aref/
          'API'
        end
      end

      def additional_entries
        entries = []

        css('dl.function', 'dl.class', 'dl.method', 'dl.attribute', 'dl.data').each do |node|
          next unless id = node.at_css('dt')['id']
          next unless name = id.dup.sub!('django.', '')

          path = name.split('.')
          type = "django.#{path.first}"
          type << ".#{path.second}" if %w(contrib db).include?(path.first)

          name.remove! 'contrib.'
          name << '()' if node['class'].include?('method') || node['class'].include?('function')

          entries << [name, id, type]
        end

        css('span[id^="std:setting-"] + h3').each do |node|
          name = node.content
          name.remove! "\u{00B6}"
          name.prepend 'settings.'
          entries << [name, node.previous_element['id'], 'settings']
        end

        entries
      end
    end
  end
end
