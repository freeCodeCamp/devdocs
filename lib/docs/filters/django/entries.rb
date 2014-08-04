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

        css('dl.function', 'dl.class', 'dl.method', 'dl.attribute').each do |node|
          next unless id = node.at_css('dt')['id']
          next unless name = id.dup.sub!('django.', '')

          path = name.split('.')
          type = "django.#{path.first}"
          type << ".#{path.second}" if %w(contrib db).include?(path.first)

          name.remove! 'contrib.'
          name << '()' if node['class'].include?('method') || node['class'].include?('function')

          entries << [name, id, type]
        end

        entries
      end

      def include_default_entry?
        at_css('#sidebar a[href="index"]')
      end
    end
  end
end
