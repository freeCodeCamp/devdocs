require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class TypstScraperTest < Minitest::Test
  def test_crawls_reference_sidebar_before_removing_navigation
    result = scrape('<h1>Reference</h1>', '')

    assert_includes result[:internal_urls], 'https://typst.app/docs/reference/math/accent/'
    refute result[:internal_urls].any? { |url| url.include?('/tutorial/') || url.include?('/changelog/') }
    assert_empty output(result).css('nav, aside, .breadcrumbs')
    assert_includes result[:output], 'https://typst.app/docs/tutorial/'
  end

  def test_indexes_types_and_their_methods_without_method_parameters
    result = scrape(<<~HTML, 'foundations/array/', 'Foundations')
      <h1 id="summary"><span class="pill pill-collect">array</span></h1>
      <h2 id="constructor">Constructor</h2>
      <h3 id="constructor-value"><code>value</code></h3>
      <h3 class="scoped-definition" id="definitions-map"><code>map</code><a class="sources-link">Go to source</a></h3>
      <div class="code code-definition">self.map(function) → array</div>
      <h4 id="definitions-map-mapper"><code>mapper</code></h4>
    HTML

    assert_equal %w(array array.map()), result[:entries].map(&:name)
    assert_equal 'Foundations', result[:entries].last.type
    assert_equal 'foundations/array/index#definitions-map', result[:entries].last.path
    assert output(result).at_css('#definitions-map')
  end

  def test_qualifies_math_functions_and_element_parameters
    result = scrape(<<~HTML, 'math/accent/', 'Math')
      <h1 id="summary"><code>accent</code><small>Element<div class="tooltip-context">Element functions can use set and show.</div></small></h1>
      <h3 id="parameters-size"><code>size</code><div class="additional-info"><div><a href="/docs/reference/layout/relative/">relative</a></div><small class="mod">Settable</small></div></h3>
    HTML

    assert_equal %w(math.accent() math.accent.size), result[:entries].map(&:name)
    assert_equal 'Math', result[:entries].first.type
    assert_equal 'accent', output(result).at_css('h1').content
    assert_equal 'size', output(result).at_css('h3').content
    assert_includes output(result).text, 'Settable'
  end

  def test_uses_module_namespace_for_grouped_functions_and_constants
    result = scrape(<<~HTML, 'foundations/calc/', 'Foundations')
      <h1>Calculation</h1>
      <h3 class="scoped-definition" id="functions-abs"><code>abs</code></h3>
      <div class="code code-definition">calc.abs(int) → int</div>
      <h3 class="scoped-definition" id="constants-pi"><code>pi</code></h3>
    HTML

    assert_equal ['Calculation', 'calc.abs()', 'calc.pi'], result[:entries].map(&:name)
  end

  def test_uses_math_namespace_for_grouped_functions
    result = scrape(<<~HTML, 'math/styles/', 'Math')
      <h1>Styles</h1>
      <h3 class="scoped-definition" id="functions-upright"><code>upright</code></h3>
      <div class="code code-definition">math.upright(content) → content</div>
    HTML

    assert_equal ['Styles', 'math.upright()'], result[:entries].map(&:name)
  end

  def test_distinguishes_element_parameters_from_scoped_functions
    result = scrape(<<~HTML, 'model/figure/', 'Model')
      <h1><code>figure</code></h1>
      <h3 id="parameters-caption"><code>caption</code></h3>
      <h3 class="scoped-definition" id="definitions-caption"><code>caption</code></h3>
      <p>The caption element.</p>
      <div class="code code-definition">figure.caption(content) → content</div>
    HTML

    assert_equal %w(figure() figure.caption() figure.caption), result[:entries].map(&:name)
  end

  def test_indexes_nested_types_and_their_methods
    result = scrape(<<~HTML, 'visualize/color/', 'Visualize')
      <h1><span class="pill">color</span></h1>
      <h3 class="scoped-definition" id="definitions-spot"><span class="pill">spot</span></h3>
      <p>A spot color.</p>
      <h4 id="definitions-spot-constructor">Constructor</h4>
      <div class="code code-definition">color.spot(str) → color.spot</div>
      <h4 id="definitions-spot-definitions">Definitions</h4>
      <h5 class="scoped-definition" id="definitions-spot-definitions-tint"><code>tint</code></h5>
      <div class="code code-definition">self.tint(ratio) → color.spot</div>
      <h6 id="definitions-spot-definitions-tint-factor"><code>factor</code><div class="additional-info"><div>ratio</div><small class="mod">Required</small></div></h6>
    HTML

    assert_equal %w(color color.spot color.spot.tint()), result[:entries].map(&:name)
    assert_equal 'Visualize', result[:entries].last.type
    assert_equal 'factor', output(result).at_css('h6').content
    assert_includes output(result).text, 'ratio Required'
  end

  def test_qualifies_export_functions
    %w(html pdf).each do |namespace|
      result = scrape('<h1><code>attach</code></h1>', "#{namespace}/attach/", namespace.upcase)
      assert_equal "#{namespace}.attach()", result[:entries].first.name
      assert_equal namespace.upcase, result[:entries].first.type
    end
  end

  def test_indexes_language_sections_and_keeps_category_overviews
    result = scrape('<h1>Syntax</h1><h2 id="math">Math mode</h2>', 'syntax/')
    assert_equal ['Syntax', 'Syntax: Math mode'], result[:entries].map(&:name)
    assert_equal ['Language'], result[:entries].map(&:type).uniq

    result = scrape('<h1>Foundations</h1>', 'foundations/')
    assert_equal 'Foundations', result[:entries].first.type
  end

  def test_preserves_code_whitespace_and_opens_rendered_examples
    result = scrape(<<~HTML, 'foundations/array/', 'Foundations')
      <h1><span class="pill">array</span></h1>
      <details class="folding-example"><summary><img src="/assets/icons/16-chevron-right.svg">View example</summary>
        <div class="previewed-code"><pre><button class="copy">Copy</button><code data-lang="typ"><span style="color: red">#let</span> values = (1, 2)
      values.map(x =&gt; x * 2)</code></pre><div class="preview"><img src="/assets/images/example.png" width="480" height="73"></div></div>
      </details>
      <div class="code code-definition">self.map(<div class="arguments"><span class="overview-param">function,</span><span class="overview-param">default: any,</span></div>) → array</div>
      <div class="code code-definition">self.position(function) → <a class="pill">none</a><a class="pill">int</a></div>
    HTML
    doc = output(result)

    assert_equal "#let values = (1, 2)\nvalues.map(x => x * 2)", doc.at_css('pre').content
    assert_equal "self.map(\n  function,\n  default: any,\n) → array", doc.css('pre')[1].content
    assert_equal 'self.position(function) → none or int', doc.css('pre').last.content
    assert doc.at_css('details').key?('open')
    assert_equal 'https://typst.app/assets/images/example.png', doc.at_css('img')['src']
    assert_empty doc.css('button, [style], [class]:not([class^="_attribution"]), [data-lang]')
  end

  def test_moves_parameter_types_modifiers_and_defaults_out_of_headings
    result = scrape(<<~HTML, 'math/accent/', 'Math')
      <h1><code>accent</code></h1>
      <h3 id="parameters-size"><code>size</code><div class="additional-info"><div>relative</div><small class="mod">Required</small><small class="mod"><span aria-describedby="tooltip-1">Settable</span><div class="tooltip-context"><div id="tooltip-1">Tooltip text</div></div></small></div><small class="default">Default: <code>100%</code></small></h3>
    HTML
    doc = output(result)

    assert_equal 'size', doc.at_css('h3').content
    assert_includes doc.text, 'relative Required Settable'
    assert_includes doc.text, 'Default: 100%'
    refute_includes doc.text, 'Tooltip text'
    assert_empty doc.css('[aria-describedby]')
    assert_empty doc.css('p > div')
  end

  def test_marks_shell_and_json_examples_for_prism_highlighting
    result = scrape(<<~HTML, 'foundations/array/', 'Foundations')
      <h1><span class="pill">array</span></h1>
      <pre><code data-lang="sh"><span style="color: #198810">typst compile main.typ</span></code></pre>
      <pre><code data-lang="json">{"name": "Typst"}</code></pre>
    HTML
    blocks = output(result).css('pre')

    assert_equal %w(bash json), blocks.map { |node| node['data-language'] }
    assert_equal ['typst compile main.typ', '{"name": "Typst"}'], blocks.map(&:content)
    assert_empty blocks.first.css('span')
  end

  def test_turns_symbol_picker_into_searchable_table_with_stable_anchors
    %w(sym emoji).each do |namespace|
      result = scrape(<<~HTML, "symbols/#{namespace}/", 'Symbols')
        <h1>Symbols</h1>
        <div class="search"><input type="search"></div>
        <ul class="symbol-grid"><li id="symbol-arrow.r" data-value="→" data-unic-name="Rightwards Arrow" data-latex-name="\\rightarrow"><button><span class="sym">→</span><code>arrow.r</code></button></li></ul>
      HTML
      entry = result[:entries].last
      assert_equal "#{namespace}.arrow.r", entry.name
      assert_equal "symbols/#{namespace}/index#symbol-arrow.r", entry.path
      row = output(result).at_xpath('.//tr[@id="symbol-arrow.r"]')
      assert_equal ['arrow.r', '→', 'Rightwards Arrow', '\\rightarrow'], row.css('td').map(&:content)
      assert_empty output(result).css('input, button')
    end
  end

  def test_symbol_without_latex_name_keeps_column_count
    result = scrape(<<~HTML, 'symbols/emoji/', 'Symbols')
      <h1>Emoji</h1>
      <ul class="symbol-grid"><li id="symbol-cat" data-value="🐈" data-unic-name="Cat" data-latex-name><button><code>cat</code></button></li></ul>
    HTML
    row = output(result).at_xpath('.//tr[@id="symbol-cat"]')
    assert_equal ['cat', '🐈', 'Cat', ''], row.css('td').map(&:content)
  end

  def test_reports_missing_category_breadcrumb
    error = assert_raises(RuntimeError) do
      html = '<div class="main-grid"><main><h1><code>accent</code></h1></main></div>'
      scraper = Docs::Typst.new
      context = scraper.options.merge(url: Docs::URL.parse("#{Docs::Typst.base_url}math/accent/"), download_images: false)
      scraper.pipeline.call(Docs::Parser.new(html).html, context)
    end
    assert_includes error.message, 'missing category breadcrumb'
  end

  private

  def scrape(body, path, category = nil)
    breadcrumbs = +'<li><a href="/docs/">Docs</a></li><li>›</li><li><a href="/docs/reference/">Reference</a></li>'
    breadcrumbs << "<li>›</li><li><a>#{category}</a></li>" if category
    breadcrumbs << '<li>›</li><li><a>Current page</a></li>' unless path.empty?
    html = <<~HTML
      <div class="main-grid">
        <nav>Sidebar<a href="/docs/reference/math/accent/">Accent</a><a href="/docs/tutorial/">Tutorial</a><a href="/docs/changelog/">Changelog</a></nav>
        <main><ul class="breadcrumbs">#{breadcrumbs}</ul>#{body}<a href="/docs/tutorial/">Tutorial</a><div class="page-end-buttons">Previous page</div></main>
        <aside>On this page</aside>
      </div>
    HTML
    scraper = Docs::Typst.new
    context = scraper.options.merge(url: Docs::URL.parse("#{Docs::Typst.base_url}#{path}"), download_images: false)
    scraper.pipeline.call(Docs::Parser.new(html).html, context)
  end

  def output(result)
    Nokogiri::HTML.fragment(result[:output])
  end
end
