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

  it "runs before CleanHtmlFilter so that MathJax <script> sources are still there" do
    filters = Docs::Scraper.html_filters.to_a
    assert_operator filters.index(Docs::MathFilter), :<, filters.index(Docs::CleanHtmlFilter)
  end

  it "does nothing when there's no math" do
    @body = '<p>Costs $5 and $10, see <code>$x$</code>.</p><div class="math">no delimiters</div>'
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

  context "MathJax 2 markup" do
    it "replaces <script type=\"math/tex\"> with inline MathML" do
      @body = '<p><span class="MathJax_Preview">x</span><script type="math/tex">x < y</script></p>'
      assert_equal 1, math_nodes.length
      assert_equal 'x < y', tex_of(math_nodes.first)
      assert_nil math_nodes.first['display']
      assert_empty filter_output.css('script, .MathJax_Preview')
    end

    it "replaces <script type=\"math/tex; mode=display\"> with display MathML" do
      @body = '<script type="math/tex; mode=display">x</script>'
      assert_equal 'block', math_nodes.first['display']
    end
  end

  context "MathJax 3 markup" do
    it "replaces <mjx-container> with its assistive MathML" do
      @body = '<p><mjx-container class="MathJax" jax="CHTML" display="true"><mjx-math></mjx-math><mjx-assistive-mml><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math></mjx-assistive-mml></mjx-container></p>'
      assert_equal '<p><math xmlns="http://www.w3.org/1998/Math/MathML" display="block"><mi>x</mi></math></p>', filter_output_string
    end

    it "leaves <mjx-container> without assistive MathML untouched" do
      @body = '<mjx-container class="MathJax"><mjx-math></mjx-math></mjx-container>'
      assert_equal @body, filter_output_string
    end
  end

  context "KaTeX markup" do
    def katex(tex, mathml: true)
      annotation = tex ? %(<annotation encoding="application/x-tex">#{tex}</annotation>) : ''
      math = mathml ? %(<span class="katex-mathml"><math xmlns="http://www.w3.org/1998/Math/MathML"><semantics><mrow><mi>z</mi></mrow>#{annotation}</semantics></math></span>) : ''
      %(<span class="katex">#{math}<span class="katex-html" aria-hidden="true"><span class="mord">z</span></span></span>)
    end

    it "re-renders the TeX source of inline math" do
      @body = %(<p><span class="math">#{katex('y = xA^T + b')}</span></p>)
      assert_equal 1, math_nodes.length
      assert_equal 'y = xA^T + b', tex_of(math_nodes.first)
      assert_includes math_nodes.first.to_s, '<mi>y</mi>'
      assert_empty filter_output.css('.katex, .katex-html, .katex-mathml')
    end

    it "re-renders the TeX source of display math" do
      @body = %(<span class="katex-display">#{katex('y')}</span>)
      assert_equal 'block', math_nodes.first['display']
      assert_empty filter_output.css('.katex-display')
    end

    it "keeps the existing MathML when there's no TeX source" do
      @body = %(<p>#{katex(nil)}</p>)
      assert_equal '<p><math xmlns="http://www.w3.org/1998/Math/MathML"><semantics><mrow><mi>z</mi></mrow></semantics></math></p>', filter_output_string
    end

    it "leaves nodes without MathML or TeX source untouched" do
      @body = katex(nil, mathml: false)
      assert_equal @body, filter_output_string
    end
  end

  context "dollar delimiters" do
    before { @body = '<p>Pay $5 and $10 for $x$ and $$y$$, not <code>$x$</code>.</p>' }

    it "are ignored by default" do
      assert_equal @body, filter_output_string
    end

    context "when context[:math_dollars] is true" do
      before { context[:math_dollars] = true }

      it "are rendered" do
        assert_equal %w(x y), math_nodes.map { |node| tex_of(node) }
        assert_equal 'block', math_nodes.last['display']
      end

      it "aren't mistaken for currency" do
        assert_includes filter_output_string, 'Pay $5 and $10 for '
      end

      it "aren't rendered inside <code>" do
        assert_equal '<code>$x$</code>', filter_output.at_css('code').to_s
      end
    end
  end
end
