# frozen_string_literal: true

module Docs
  class CleanLocalUrlsFilter < Filter
    def call
      if base_url.host == 'localhost'
        css('img[src^="http://localhost"]', 'iframe[src^="http://localhost"]').remove

        css('a[href^="http://localhost"]').each do |node|
          node.name = 'span'
          node.remove_attribute 'href'
        end
      end

      doc
    end
  end
end
