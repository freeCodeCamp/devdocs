module Docs
  class Http
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if current_url.host == 'tools.ietf.org'
          name = at_css('h1').content
          name.remove! %r{\A.+\:}
          name.remove! %r{\A.+\-\-}
          rfc = slug.sub('rfc', 'RFC ')
          "#{rfc}: #{name.strip}"
        elsif slug.start_with?('Status')
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
        return 'RFC' if current_url.host == 'tools.ietf.org'

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
    end
  end
end
