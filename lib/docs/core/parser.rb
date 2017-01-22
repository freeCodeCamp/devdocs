module Docs
  class Parser
    attr_reader :title, :html

    def initialize(content)
      @content = content
      @html = document? ? parse_as_document : parse_as_fragment
    end

    private

    DOCUMENT_RGX = /\A(?:\s|(?:<!--.*?-->))*<(?:\!doctype|html)/i

    def document?
      @content =~ DOCUMENT_RGX
    end

    def parse_as_document
      document = Nokogiri::HTML.parse @content, nil, 'UTF-8'
      @title = document.at_css('title').try(:content)
      document
    end

    def parse_as_fragment
      Nokogiri::HTML.fragment @content, 'UTF-8'
    end
  end
end
