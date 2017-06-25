module Docs
  class Redux
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.page-inner h1, .page-inner h2').content
        name.sub! %r{\(.*\)}, '()'
        name
      end

      def get_type
        path = slug.split('/')

        if path.length > 1
          path[0].titleize.sub('Api', 'API').sub('Faq', 'FAQ')
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        css('#store-methods + ul > li > a').map do |node|
          id = node['href'].remove('#')
          name = "#{self.name}##{id}()"
          [name, id]
        end
      end
    end
  end
end
