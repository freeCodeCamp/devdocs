# frozen_string_literal: true

module Docs
  class Cypress
    class CleanHtmlFilter < Filter
      def call

        css('div[role=alert]').each do |node|
          node.name = 'blockquote'
          node.add_class('note info')
        end

        css('footer').remove

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
