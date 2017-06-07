require 'test_helper'
require 'docs'

class UsagesFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Go::UsagesFilter

  before do
    context[:base_url] = 'http://example.com/path/'
    context[:url] = 'http://example.com/path/bytes/'
  end

  it "adds examples link for functions" do
    @body = '<div><h2 id="Contains">func Contains  </h2></div>'
    assert_equal "<div>\n"\
                 "<h2 id=\"Contains\">func Contains  </h2>\n"\
                 "<a href=\"https://sourcegraph.com/github.com/golang/go/-/land/GoPackage/bytes/-/Contains?utm_source=devdocs.io&amp;utm_medium=web&amp;utm_campaign=docs\">Examples</a>\n"\
                 "</div>", filter_output_string
  end

  it "adds examples link for methods" do
    @body =
      '<div><h3 id="Buffer.WriteString">func (*Buffer) <a href="https://golang.org/src/bytes/buffer.go?s=4916:4973#L131">WriteString</a>  </h3></div>'
    assert_equal "<div>\n"\
                 "<h3 id=\"Buffer.WriteString\">func (*Buffer) <a href=\"https://golang.org/src/bytes/buffer.go?s=4916:4973#L131\">WriteString</a>  </h3>\n"\
                 "<a href=\"https://sourcegraph.com/github.com/golang/go/-/land/GoPackage/bytes/-/Buffer/WriteString?utm_source=devdocs.io&amp;utm_medium=web&amp;utm_campaign=docs\">Examples</a>\n"\
                 "</div>", filter_output_string
  end

  it "adds examples link for variables" do
    @body =
      "<div>\n"\
      "<h2 id=\"pkg-variables\">Variables</h2>\n"\
      "<pre data-language=\"go\" class=\" language-go\"><span class=\"token keyword\">var</span> ErrTooLarge <span class=\"token operator\">=</span> errors<span class=\"token punctuation\">.</span><span class=\"token function\">New</span><span class=\"token punctuation\">(</span><span class=\"token string\">\"bytes.Buffer: too large\"</span><span class=\"token punctuation\">)</span></pre>\n"\
      "</div>"

    assert_equal "<div>\n"\
                 "<h2 id=\"pkg-variables\">Variables</h2>\n"\
                 "<pre data-language=\"go\" class=\" language-go\"><span class=\"token keyword\">var</span> ErrTooLarge <span class=\"token operator\">=</span> errors<span class=\"token punctuation\">.</span><span class=\"token function\">New</span><span class=\"token punctuation\">(</span><span class=\"token string\">\"bytes.Buffer: too large\"</span><span class=\"token punctuation\">)</span></pre>\n"\
                 "<div><a href=\"https://sourcegraph.com/github.com/golang/go/-/land/GoPackage/bytes/-/ErrTooLarge?utm_source=devdocs.io&amp;utm_medium=web&amp;utm_campaign=docs\">ErrTooLarge examples</a></div>\n"\
                 "</div>", filter_output_string
  end

  it "adds examples link for constants" do
    @body =
      "<div>\n"\
      "<h2 id=\"pkg-constants\">Constants</h2>\n"\
      "<pre data-language=\"go\" class=\" language-go\"><span class=\"token keyword\">const</span> Size <span class=\"token operator\">=</span> <span class=\"token number\">4</span></pre>\n"\
      "</div>"

    assert_equal "<div>\n"\
                 "<h2 id=\"pkg-constants\">Constants</h2>\n"\
                 "<pre data-language=\"go\" class=\" language-go\"><span class=\"token keyword\">const</span> Size <span class=\"token operator\">=</span> <span class=\"token number\">4</span></pre>\n"\
                 "<div><a href=\"https://sourcegraph.com/github.com/golang/go/-/land/GoPackage/bytes/-/Size?utm_source=devdocs.io&amp;utm_medium=web&amp;utm_campaign=docs\">Size examples</a></div>\n"\
                 "</div>", filter_output_string
  end

end
