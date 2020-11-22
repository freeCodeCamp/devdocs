module Docs
  class Pandas
    class CleanHtmlFilter < Filter
      def call

        css('#navbar-main').remove

        css('form').remove

        # sidebar
        css('ul.nav.bd-sidenav').remove

        # title side symbol
        css('.headerlink').remove

        # next and previous section buttons
        css('next-link').remove
        css('prev-link').remove

        css('footer').remove

        doc
      end
    end
  end
end
