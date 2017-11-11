# frozen_string_literal: true

module Docs
  class RougeFilter < Filter
    def call
      css('div.highlighter-rouge').each do |node|
        node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class']
        node.content = node.content.strip
        node.name = 'pre'
      end

      css('.highlighter-rouge').remove_attr('class')

      doc
    end
  end
end
