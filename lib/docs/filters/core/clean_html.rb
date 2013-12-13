module Docs
  class CleanHtmlFilter < Filter
    def call
      css('script', 'style').remove
      xpath('descendant::comment()').remove
      xpath('./text()', './/text()[not(ancestor::pre) and not(ancestor::code)]').each do |node|
        content = node.content
        next unless content.valid_encoding?
        content.gsub! %r{[[:space:]]+}, ' '
        node.content = content
      end
      doc
    end
  end
end
