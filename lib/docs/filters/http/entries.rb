module Docs
  class Http
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if current_url.host == 'datatracker.ietf.org'
          name = at_css('h1').content
          name.remove! %r{\A.+\:}
          name.remove! %r{\A.+\-\-}
          name = 'WebDAV' if name.include?('WebDAV')
          "#{rfc}: #{name.strip}"
        elsif slug.start_with?('Status/')
          at_css('code').content
        else
          name = super
          name.remove! %r{\A\w+\.}
          name.remove! 'Basics of HTTP.'
          name.sub! 'Content-Security-Policy.', 'CSP.'
          name.sub! '.', ': '
          name.sub! '1: x', '1.x'
          name
        end
      end

      def get_type
        return name if current_url.host == 'datatracker.ietf.org'

        if slug.start_with?('Headers/Content-Security-Policy')
          'CSP'
        elsif slug.start_with?('Headers')
          'Headers'
        elsif slug.start_with?('Methods')
          'Methods'
        elsif slug.start_with?('Status')
          'Status'
        elsif slug.start_with?('Basics_of_HTTP')
          'Guides: Basics'
        else
          'Guides'
        end
      end

      def rfc
        slug.sub('rfc', 'RFC ')
      end

      SECTIONS = {
        'rfc4918' => [
          [],
          [11],
          [], []
        ],
        'rfc9110' => [
          (3..18).to_a,
          (3..17).to_a,
          (7..15).to_a,
          []
        ],
        'rfc9111' => [
          (3..8).to_a,
          (3..10).to_a,
          [],
          [5]
        ],
        'rfc9112' => [
          (2..12).to_a,
          (2..11).to_a,
          [], []
        ],
        'rfc9113' => [
          (3..11).to_a,
          (3..10).to_a,
          [], []
        ],
        'rfc9114' => [
          (3..11).to_a,
          (3..10).to_a,
          [7], []
        ],
        'rfc5023' => [
          [], [], [], []
        ]
      }

      LEVEL_1 = /\A(\d+)\z/
      LEVEL_2 = /\A(\d+)\.\d+\z/
      LEVEL_3 = /\A(\d+)\.\d+\.\d+\z/
      LEVEL_4 = /\A(\d+)\.\d+\.\d+\.\d+\z/

      def additional_entries
        return [] unless current_url.host == 'datatracker.ietf.org'
        type = nil

        css('*[id^="section-"]').each_with_object([]) do |node, entries|
          id = node['id']
          break entries if entries.any? { |e| e[1] == id }

          content = node.content.strip
          content.remove! %r{\s*\.+\d*\z}
          content.remove! %r{\A[\.\s]+}

          name = "#{content} (#{rfc})"
          number = id.remove('section-')

          if number =~ LEVEL_1
            if SECTIONS[slug][0].include?($1.to_i)
              entries << [name, id, self.name]
            end

            type = content.sub(/\ Definitions\z/, 's')
            if type.include?('Header Fields')
              type = 'Headers'
            elsif type.include?('Status Codes')
              type = 'Status'
            elsif type.include?('Methods')
              type = 'Methods'
            else
              type = self.name
            end
          elsif (number =~ LEVEL_2 && SECTIONS[slug][1].include?($1.to_i)) ||
                (number =~ LEVEL_3 && SECTIONS[slug][2].include?($1.to_i)) ||
                (number =~ LEVEL_4 && SECTIONS[slug][3].include?($1.to_i))
            if type != self.name
              name.remove! %r{\A(\d+\.)* }
            end
            entries << [name, id, (name =~ /\A\d\d\d/ ? 'Status' : type )]
          end
        end
      end
    end
  end
end
