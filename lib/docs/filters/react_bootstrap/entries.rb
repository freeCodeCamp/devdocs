module Docs
  class ReactBootstrap
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('#rb-docs-content h1, #rb-docs-content h2').content
        if name.end_with? '#'
          name = name[0..-2]
        end
        name
      end

      def get_type
        type = slug.split('/')[0..-2].join(': ')
        if type == ''
          type = slug.split('/').join('')
        end
        type.gsub!('-', ' ')
        type = type.split.map(&:capitalize).join(' ')
        type
      end
    end
  end
end
