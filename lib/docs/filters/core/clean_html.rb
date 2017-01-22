# frozen_string_literal: true

module Docs
  class CleanHtmlFilter < Filter
    def call
      css('script', 'style', 'link').remove
      xpath('descendant::comment()').remove
      xpath('./text()', './/text()[not(ancestor::pre) and not(ancestor::code) and not(ancestor::div[contains(concat(" ", normalize-space(@class), " "), " prism ")])]').each do |node|
        content = node.content
        next unless content.valid_encoding?
        content.gsub! %r{[[:space:]]+}, ' '
        node.content = content
      end
      doc
    end
  end
end
