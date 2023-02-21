require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

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
        html = parser(body).html
        assert_equal '#document-fragment', html.name
        assert_equal body, html.inner_html
      end
    end

    context "with an HTML document" do
      it "returns the document" do
        body = '<!-- foo --> <!doctype html><meta charset=utf-8><title></title><div>Test</div>'
        html = parser(body).html
        assert_equal 'document', html.name
        assert_equal '<div>Test</div>', html.at_css('body').inner_html

        body = '<html><meta charset=utf-8><title></title><div>Test</div></html>'
        html = parser(body).html
        assert_equal 'document', html.name
        assert_equal '<div>Test</div>', html.at_css('body').inner_html
      end
    end
  end

  describe "#title" do
    it "returns nil when there is no <title>" do
      body = '<!doctype html><meta charset=utf-8><div>Test</div>'
      assert_nil parser(body).title
    end

    it "returns the <title> when there is one" do
      body = '<!doctype html><meta charset=utf-8><title>Title</title><div>Test</div>'
      assert_equal 'Title', parser(body).title
    end
  end
end
