# frozen_string_literal: true

module Docs
  class Qunit
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.content[role="main"]')
        css('.sidebar').remove
        doc
      end
    end
  end
end
