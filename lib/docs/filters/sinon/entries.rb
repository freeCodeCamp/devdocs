module Docs
  class Sinon
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = config = nil

        css('*').each do |node|
          if node.name == 'h2'
            config = false
            type = node.content.strip
            type.remove! 'Test '
            type.remove! 'Sinon.JS '
            type = type[0].upcase + type.from(1)

            id = type.parameterize
            node['id'] = id

            entries << [type, id, 'Sections']
          elsif node.name == 'h3' && node.content.include?('sinon.config')
            config = true
          elsif node.name == 'dl'
            node.css('dt > code').each do |code|
              name = code.content.strip
              name.sub! %r{\(.*\);?}, '()'
              name.sub! %r{\Aserver.(\w+)\s=.*\z}, 'server.\1'
              name.remove! '`'
              name.remove! %r{\A.+?\=\s+}
              name.remove! %r{\A\w+?\s}
              name.prepend 'sinon.config.' if config

              next if name =~ /\s/
              next if entries.any? { |entry| entry[0].casecmp(name) == 0 }

              id = name.parameterize
              code.parent['id'] = id

              entries << [name, id, type]
            end
          end
        end

        entries
      end
    end
  end
end
