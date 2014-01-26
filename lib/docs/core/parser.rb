module Docs
  class Parser
    def initialize(content)
      @content = content
    end

    def html
      @html ||= document? ? parse_as_document : parse_as_fragment
    end

    private

    def document?
      @content =~ /\A\s*<!doctype/i
    end

    def parse_as_document
      document = Nokogiri::HTML.parse @content, nil, 'UTF-8'
      document.at_css 'body'
    end

    def parse_as_fragment
      Nokogiri::HTML.fragment @content, 'UTF-8'
    end
  end
end
