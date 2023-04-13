module Docs
  class Http
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('Status/')
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
        elsif slug.start_with?('Headers/Permissions-Policy')
          'Permissions-Policy'
        elsif slug.start_with?('CORS/Errors')
          'CORS errors'
        elsif slug.start_with?('Headers')
          'Headers'
        elsif slug.start_with?('Methods')
          'Methods'
        elsif slug.start_with?('Status')
          'Status'
        else
          'Guides'
        end
      end

    end
  end
end
