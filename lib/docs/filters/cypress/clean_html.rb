# frozen_string_literal: true

module Docs
  class Cypress
    class CleanHtmlFilter < Filter
      def call
        css('.article-edit-link').remove
        css('#sidebar').remove
        css('article footer').remove
        css('#article-toc').remove
        css('.article-footer-updated').remove

        doc
      end
    end
  end
end
