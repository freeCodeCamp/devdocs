# frozen_string_literal: true

module Docs
  class Cypress
    class CleanHtmlFilter < Filter
      def call
        article_div = at_css('#article > div')
        @doc = article_div unless article_div.nil?

        header = at_css('h1.article-title')
        doc.prepend_child(header) unless header.nil?

        css('.article-edit-link').remove
        css('.article-footer').remove
        css('.article-footer-updated').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
