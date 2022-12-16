# frozen_string_literal: true

module Docs
  class Qunit
    class CleanHtmlFilter < Filter
      def call
        css('.sidebar').remove
        doc
      end
    end
  end
end
