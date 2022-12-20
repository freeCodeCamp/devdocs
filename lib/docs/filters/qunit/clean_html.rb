# frozen_string_literal: true

module Docs
  class Qunit
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content[role="main"]')
        css('.sidebar').remove
        css('pre').each do |node|
          node['data-language'] = 'javascript'
          node.content = node.content
        end
        doc
      end
    end
  end
end
