require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class MathFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::MathFilter
  self.filter_type = 'html'

  def math_nodes
    filter_output.css('math')
  end

  def tex_of(node)
    node.at_css('annotation[encoding="application/x-tex"]').content
  end

  it "does nothing when there's no math" do
    @body = '<p>Costs $5</p><div class="math">no delimiters</div>'
    assert_equal @body, filter_output_string
  end

  it "leaves existing <math> elements untouched" do
    @body = '<p><math><mi>x</mi></math></p>'
    assert_equal @body, filter_output_string
  end

  context "Sphinx markup" do
    it "replaces <span class=\"math\"> with inline MathML" do
      @body = '<p>Let <span class="math notranslate nohighlight">\(x \in \mathbb{R}^d\)</span> be</p>'
      assert_equal 1, math_nodes.length
      assert_equal 'x \in \mathbb{R}^d', tex_of(math_nodes.first)
      assert_nil math_nodes.first['display']
      assert_empty filter_output.css('.math')
      assert_equal 'Let ', filter_output.at_css('math').previous.content
    end

    it "replaces <div class=\"math\"> with display MathML" do
      @body = %(<div class="math notranslate nohighlight">\n\\[\\begin{split}a &amp;= b \\\\ &amp;= c\\end{split}\\]</div>)
      assert_equal 1, math_nodes.length
      assert_equal 'block', math_nodes.first['display']
      assert_equal '\begin{split}a &= b \\\\ &= c\end{split}', tex_of(math_nodes.first)
      assert_equal [filter_output.at_css('math')], filter_output.element_children.to_a
    end

    it "renders every expression in the node" do
      @body = '<div class="math">\[a\]\[b\]</div>'
      assert_equal %w(a b), math_nodes.map { |node| tex_of(node) }
    end

    it "keeps the surrounding text" do
      @body = '<span class="math">see \(a\) and \(b\)</span>'
      assert_match %r{\Asee <math.+</math> and <math.+</math>\z}, filter_output_string
    end

    it "keeps the equation id and drops the equation number" do
      @body = '<div class="math" id="equation-foo"><span class="eqno">(1)<a class="headerlink" href="#equation-foo">¶</a></span>\[a\]</div>'
      assert_equal 'equation-foo', math_nodes.first['id']
      assert_empty filter_output.css('.eqno, .headerlink')
      assert_equal 1, filter_output.children.length
    end

    it "shows the TeX source when it can't be rendered" do
      @body = '<p><span class="math">\(\frac{a\)</span> <div class="math">\[\frac{b\]</div></p>'
      assert_empty math_nodes
      assert_equal '<code class="_math-fallback">\frac{a</code>', filter_output.at_css('code').to_s
      assert_equal '<pre class="_math-fallback">\frac{b</pre>', filter_output.at_css('pre').to_s
    end
  end
end
