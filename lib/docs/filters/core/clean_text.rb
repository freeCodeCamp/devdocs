# frozen_string_literal: true

module Docs
  class CleanTextFilter < Filter
    EMPTY_NODES_RGX = /<(?!td|th|iframe|mspace)(\w+)[^>]*>[[:space:]]*<\/\1>/

    def call
      return html if context[:clean_text] == false
      html.strip!
      while html.gsub!(EMPTY_NODES_RGX, ''); end
      html
    end
  end
end
