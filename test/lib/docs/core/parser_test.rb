require 'test_helper'
require 'docs'

class DocsParserTest < MiniTest::Spec
  def parser(content)
    Docs::Parser.new(content)
  end

  describe "#html" do
    it "returns a Nokogiri Node" do
      assert_kind_of Nokogiri::XML::Node, parser('').html
    end

    context "with an HTML fragment" do
      it "returns the fragment" do
        body = '<div>Test</div>'
        assert_equal body, parser(body).html.inner_html
      end
    end

    context "with an HTML document" do
      it "returns the <body>" do
        body = '<!doctype html><meta charset=utf-8><title></title><div>Test</div>'
        assert_equal '<div>Test</div>', parser(body).html.inner_html
      end
    end
  end
end
