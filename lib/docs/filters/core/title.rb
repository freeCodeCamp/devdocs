# frozen_string_literal: true

module Docs
  class TitleFilter < Filter
    def call
      title = self.title
      doc.child.before node(title) if title
      doc
    end

    def title
      if !context[:root_title].nil? && root_page?
        context[:root_title]
      elsif !context[:title].nil?
        context[:title].is_a?(Proc) ? context[:title].call(self) : context[:title]
      else
        default_title
      end
    end

    def default_title
      result[:entries].try(:first).try(:name)
    end

    def node(content)
      node = Nokogiri::XML::Node.new 'h1', doc
      node.content = content
      node
    end
  end
end
