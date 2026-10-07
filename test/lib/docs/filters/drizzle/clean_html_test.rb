require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class DrizzleCleanHtmlFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Drizzle::CleanHtmlFilter
  self.filter_type = 'html'

  before do
    context[:base_url] = 'https://orm.drizzle.team/docs/'
    context[:url] = 'https://orm.drizzle.team/docs/select'
    context[:root_path] = 'overview'
  end

  def page(content)
    <<-HTML
      <div class="nav-items">
        <div class="nav-separator">Access your data</div>
        <a class="nav-item--active" href="/docs/select">Select</a>
      </div>
      <main class="documentation-container"><div class="documentation-content">#{content}</div></main>
    HTML
  end

  def snippet(code, language: 'ts', title: nil, hidden: false)
    <<-HTML
      <figure class="code-snippet lang-plaintext#{' hidden' if hidden}" style="position:relative">
        <figcaption class="header">#{%(<span class="title">#{title}</span>) if title}<button class="button-wrap button-wrap--title"><svg></svg></button></figcaption>
        <pre class="astro-code css-variables" style="color:var(--astro-code-color-text)" tabindex="0" data-language="#{language}"><code>#{code.lines.map { |line| %(<span class="line"><span style="color:red">#{line.chomp}</span></span>) }.join("\n")}</code></pre>
        <div class="btn-container"><button aria-label="Copy" data-copy-btn="" class="button-wrap" data-code="#{code}"><svg></svg></button></div>
      </figure>
    HTML
  end

  it "keeps the documentation's content only" do
    @body = page('<h1 id="sql-select">SQL Select<a href="#sql-select" class="autolink-header"><span class="icon icon-link"></span></a></h1><p>Text</p>')
    assert_equal '<h1 id="sql-select">SQL Select</h1><p>Text</p>', filter_output.inner_html.squish.gsub('> <', '><')
  end

  it "titles the pages without a title after their sidebar label" do
    @body = page('<h2 id="type-api">Type API</h2>')
    assert_equal 'Select', filter_output.at_css('h1').content
  end

  it "turns code snippets into plain <pre> elements, with the language as Prism names it" do
    @body = page(snippet("const a = 1;\nconst b = 2;"))
    pre = filter_output.at_css('pre')
    assert_equal "const a = 1;\nconst b = 2;", pre.content
    assert_equal({ 'data-language' => 'typescript' }, pre.attributes.transform_values(&:value))
    assert_nil filter_output.at_css('figure, button, svg')
  end

  it "doesn't set a language on plain text snippets" do
    @body = page(snippet('plain', language: 'plaintext'))
    assert_nil filter_output.at_css('pre')['data-language']
  end

  it "titles the snippets after their file name" do
    @body = page(snippet('code', title: 'schema.ts'))
    assert_equal 'schema.ts', filter_output.at_css('pre').previous_element.content
    assert_equal '_pre-heading', filter_output.at_css('pre').previous_element['class']
  end

  it "turns code tabs into consecutive snippets titled after their tab" do
    @body = page(<<-HTML)
      <div class="codetabs_wrapper">
        <div class="codetabs_tabs"><div class="codetabs_tab--active">index.ts</div><div class="codetabs_tab">schema.ts</div></div>
        <div class="code codetabs_codeBlock">
          #{snippet('query')}
          <div class="section__wrap hidden">#{snippet('schema')}#{snippet('create table', language: 'sql')}</div>
        </div>
      </div>
    HTML

    assert_equal ['index.ts', 'query', 'schema.ts', 'schema', 'create table'], filter_output.css('._pre-heading, pre').map(&:content)
    assert_nil filter_output.at_css('.codetabs_wrapper, .codetabs_tabs, .section__wrap')
  end

  it "turns tabs into consecutive blocks titled after their tab" do
    @body = page(<<-HTML)
      <div class="tabs__wrap">
        <div class="tabs__buttons"><div class="tabs__button--active"> Query Builder </div><div class="tabs__button"> Callback </div></div>
        <div class="tabs__content"><div class="tab__content">#{snippet('builder')}</div><div class="tab__content hidden">#{snippet('callback')}</div></div>
      </div>
    HTML

    assert_equal ['Query Builder', 'builder', 'Callback', 'callback'], filter_output.css('._pre-heading, pre').map(&:content)
  end

  it "keeps the npm commands of the package manager tabs only" do
    @body = page(<<-HTML)
      <div class="npm__wrapper">
        <div class="npm__tabs"><div class="npm__tab--active">npm</div><div class="npm__tab">yarn</div></div>
        <div class="npm__content">#{snippet('npm i drizzle-orm', language: '')}#{snippet('yarn add drizzle-orm', language: '', hidden: true)}</div>
      </div>
    HTML

    assert_equal ['npm i drizzle-orm'], filter_output.css('pre').map(&:content)
    assert_equal 'bash', filter_output.at_css('pre')['data-language']
    refute_includes filter_output_string, 'yarn'
  end

  it "turns callouts into notes, titled after their label" do
    @body = page(<<-HTML)
      <div class="callout-label warning">IMPORTANT</div>
      <div class="callout-wrap"><div class="callout-content"><div class="content"><p>Note</p></div></div></div>
      <div class="callout-label error">WARNING</div>
      <div class="callout-wrap"><div class="callout-content"><div class="content"><p>Warning</p></div></div></div>
    HTML

    notes = filter_output.css('div')
    assert_equal ['_note', '_note _note-red'], notes.map { |note| note['class'] }
    assert_equal [['IMPORTANT', 'Note'], ['WARNING', 'Warning']], notes.map { |note| note.css('p').map(&:content) }
  end

  it "titles collapsed callouts after their title, but not after their toggle's label" do
    @body = page(<<-HTML)
      <div class="callout-wrap callout-wrap-collapsed"><div class="callout-content">
        <div><button data-callout-collapse-btn class="button-wrap"><svg></svg></button><p class="collapsed-label">How it works?</p></div>
        <div class="content">
          <p>Outer</p>
          <div class="callout-wrap callout-wrap-collapsed"><div class="callout-content">
            <div><p class="collapsed-label">Expand details</p></div>
            <div class="content"><p>Inner</p></div>
          </div></div>
        </div>
      </div></div>
    HTML

    outer = filter_output.at_css('div._note')
    assert_equal 'How it works?', outer.at_css('> p > strong').content
    assert_equal 'Inner', outer.at_css('div._note').content.strip
  end

  it "removes the Markdown thematic breaks rendered as headings" do
    @body = page('<h2 id="---">---</h2><h3 id="filters">Filters</h3>')
    assert_equal ['Select', 'Filters'], filter_output.css('h1, h3').map(&:content)
    assert_nil filter_output.at_css('h2')
  end

  it "removes the links to the pages to read next" do
    @body = page('<p>Text</p><h4 id="whats-next">What’s next?</h4><br><div class="flex-container"><a href="/docs/select">Select</a></div>')
    assert_equal '<h1>Select</h1><p>Text</p>', filter_output.inner_html.squish.gsub('> <', '><')
  end

  it "removes the empty first column of tables" do
    @body = page('<table><thead><tr><th></th><th>param</th></tr></thead><tbody><tr><td></td><td>value</td></tr></tbody></table>')
    assert_equal ['param', 'value'], filter_output.css('th, td').map(&:content)
  end

  it "removes the attributes and classes of the website" do
    @body = page('<p style="margin: 0" data-astro-cid-x class="link">Text</p>')
    assert_equal({}, filter_output.at_css('p').attributes)
  end
end
