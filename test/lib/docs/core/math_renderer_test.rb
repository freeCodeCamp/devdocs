require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsMathRendererTest < Minitest::Spec
  let(:renderer) { Docs::MathRenderer }

  describe ".to_mathml" do
    it "returns a <math> element" do
      output = renderer.to_mathml('x^2')
      assert_match %r{\A<math [^>]*>.*</math>\z}m, output
      refute_includes output, 'class="katex"'
    end

    it "keeps the TeX source as an annotation" do
      assert_includes renderer.to_mathml('x \in \mathbb{R}'),
                      '<annotation encoding="application/x-tex">x \in \mathbb{R}</annotation>'
    end

    it "renders inline math by default" do
      refute_includes renderer.to_mathml('x^2'), 'display="block"'
    end

    it "renders display math when display is true" do
      assert_includes renderer.to_mathml('x^2', display: true), '<math xmlns="http://www.w3.org/1998/Math/MathML" display="block">'
    end

    it "accepts bare underscores in text mode, like MathJax does" do
      output = renderer.to_mathml('\text{log_loss}(y) + n_{\text{nonzero\_coefs}}')
      assert_includes output, '<mtext>log_loss</mtext>'
      assert_includes output, '<mtext>nonzero_coefs</mtext>'
    end

    it "raises an Error when the TeX can't be parsed" do
      error = assert_raises(Docs::MathRenderer::Error) { renderer.to_mathml('\frac{a') }
      assert_includes error.message, 'KaTeX parse error'
    end

    it "raises a SetupError when no JavaScript runtime is available" do
      renderer.reset!
      stub(ExecJS).compile { raise ExecJS::RuntimeUnavailable }
      assert_raises(Docs::SetupError) { renderer.to_mathml('x') }
      renderer.reset!
    end
  end

  describe ".render_all" do
    it "renders many expressions at once, in order" do
      results = renderer.render_all([['a', false], ['\frac{', true], ['b', true]])
      assert_equal 3, results.length
      assert_includes results[0][:mathml], '<mi>a</mi>'
      assert_kind_of Docs::MathRenderer::Error, results[1][:error]
      assert_includes results[2][:mathml], 'display="block"'
      assert_includes results[2][:mathml], '<mi>b</mi>'
    end

    it "returns an empty array when given nothing" do
      assert_equal [], renderer.render_all([])
    end
  end

  describe ".render" do
    it "returns MathML for valid TeX" do
      assert_match %r{\A<math}, renderer.render('x')
    end

    it "falls back to the escaped TeX source for invalid inline TeX" do
      assert_equal '<code class="_math-fallback">\frac{a &lt; b</code>', renderer.render('\frac{a < b')
    end

    it "falls back to a <pre> for invalid display TeX" do
      assert_equal '<pre class="_math-fallback">\frac{a</pre>', renderer.render('\frac{a', display: true)
    end
  end
end
