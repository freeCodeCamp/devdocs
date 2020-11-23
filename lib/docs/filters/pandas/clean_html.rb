module Docs
  class Pandas
    class CleanHtmlFilter < Filter
      def call

        if root_page?
          css('img').remove
        end

        css('#navbar-main').remove

        css('form').remove

        # add ':' to '.classifier' clases
        css('.classifier').each do |node|
          text = node.content
          node.content = ':' + text
          node.content = node.content.gsub(/::/, ' : ')
        end

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
