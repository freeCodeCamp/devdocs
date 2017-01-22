# frozen_string_literal: true

module Docs
  class InnerHtmlFilter < Filter
    def call
      html = doc.inner_html
      html = html.encode('UTF-16', invalid: :replace, replace: '').encode('UTF-8') unless html.valid_encoding?
      html
    end
  end
end
