module Docs
  class RabbitMq
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        breadcrumb = css('.breadcrumbs__item')

        if breadcrumb.length > 1
          breadcrumb[1].inner_text
        else
          'Other'
        end
      end
    end
  end
end
