# frozen_string_literal: true

module Docs
  class CleanTextFilter < Filter
    EMPTY_NODES_RGX = /<(?!td|th|iframe|mspace|rect|path|ellipse|line|polyline)(\w+)[^>]*>[[:space:]]*<\/\1>/

    def call
      return html if context[:clean_text] == false

      # Clone frozen literal.
      result = html.dup
      result.strip!
      while result.gsub!(EMPTY_NODES_RGX, ''); end
      result
    end
  end
end
