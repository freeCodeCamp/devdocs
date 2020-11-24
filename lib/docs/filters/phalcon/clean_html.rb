module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call

        # left navigation bar
        css('.doc-article-nav-wr').remove

        # right navigation bar
        css('.phalcon-blog__right-item').remove

        css('header').remove

        css('footer').remove

        # initial table of contents
        if !(slug=='index')
          css('.docSearch-content > ul').remove
        end

        doc

      end
    end
  end
end
