module Docs
  class Http
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if current_url.host == 'tools.ietf.org'
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
        return name if current_url.host == 'tools.ietf.org'

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
        'rfc2616' => [
          [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15],
          [14],
          []
        ],
        'rfc4918' => [
          [],
          [11],
          []
        ],
        'rfc7230' => [
          (2..9).to_a,
          [],
          []
        ],
        'rfc7231' => [
          [3, 8, 9],
          [],
          [4, 5, 6, 7]
        ],
        'rfc7232' => [
          [5, 6, 7, 8],
          [2, 3, 4],
          []
        ],
        'rfc7233' => [
          [5, 6],
          [2, 3, 4],
          []
        ],
        'rfc7234' => [
          [3, 6, 7, 8],
          [4, 5],
          []
        ],
        'rfc7235' => [
          [2, 5, 6],
          [3, 4],
          []
        ],
        'rfc5023' => [
          [],
          [],
          []
        ]
      }

      LEVEL_1 = /\A(\d+)\z/
      LEVEL_2 = /\A(\d+)\.\d+\z/
      LEVEL_3 = /\A(\d+)\.\d+\.\d+\z/

      def additional_entries
        return [] unless current_url.host == 'tools.ietf.org'
        type = nil

        css('a[href^="#section-"]').each_with_object([]) do |node, entries|
          id = node['href'].remove('#')
          break entries if entries.any? { |e| e[1] == id }

          content = node.next.content.strip
          content.remove! %r{\s*\.+\d*\z}
          content.remove! %r{\A[\.\s]+}

          name = "#{content} (#{rfc})"
          number = node.content.strip

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
                (number =~ LEVEL_3 && SECTIONS[slug][2].include?($1.to_i))
            entries << [name, id, (name =~ /\A\d\d\d/ ? 'Status' : type )]
          end
        end
      end
    end
  end
end
