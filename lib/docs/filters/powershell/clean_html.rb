module Docs
  class Powershell
    class CleanHtmlFilter < Filter
      def call
        # web
        css('header').remove
        css('#ms--content-header').remove
        css('#article-header').remove
        css('.left-container').remove
        css('.layout-body-aside').remove
        css('#site-user-feedback-footer').remove
        css('footer').remove
        # docfx
        css('.sideaffix').remove
        # markdown-folder-to-html
        css('#menuLink').remove
        css('#menu').remove
        css('script').remove
        css('style').remove
        doc
      end
    end
  end
end
