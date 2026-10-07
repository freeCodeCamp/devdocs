require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class TanstackCleanHtmlFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Tanstack::CleanHtmlFilter

  before do
    context[:url] = 'https://tanstack.com/query/latest/docs/framework/react/overview'
    context[:base_url] = 'https://tanstack.com/query/latest/docs/'
  end

  it 'keeps the title and the prose and drops the sidebar' do
    @body = <<-HTML
      <nav><a href="https://tanstack.com/query/latest/docs/framework/react/guides/queries">Queries</a></nav>
      <h1>Overview</h1>
      <footer><h2>Libraries</h2></footer>
      <div class="prose">
        <h2 id="motivation">Motivation<a href="#motivation" class="anchor-heading-link">#</a></h2>
        <p>Fetch data. <a href="https://stackblitz.com/edit/demo">Open in StackBlitz</a></p>
      </div>
    HTML

    output = filter_output
    assert_equal 'Overview', output.at_css('h1').content
    assert_equal 1, output.css('h1').length
    assert_nil output.at_css('nav')
    assert_nil output.at_css('footer')
    assert_equal 'Motivation', output.at_css('h2').content.strip
    assert_equal 'motivation', output.at_css('h2')['id']
    assert_includes output.at_css('a')['href'], 'stackblitz.com'
  end

  it 'flattens highlighted code and renames languages Prism knows' do
    @body = <<-HTML
      <h1>Queries</h1>
      <div class="prose">
        <div class="codeblock"><div>tsx</div><button>Copy</button>
          <pre class="th-code th-code--tsx" data-language="tsx"><code><span class="th-token th-keyword">const</span> value = 1</code></pre>
        </div>
        <pre class="th-code th-code--ts" data-language="ts"><code>type Id = string</code></pre>
        <pre class="th-code th-code--js" data-language="js"><code>const n = 1</code></pre>
        <pre class="th-code th-code--shell" data-language="shell"><code>npm install</code></pre>
        <pre class="th-code th-code--json" data-language="json"><code>{"a":1}</code></pre>
      </div>
    HTML

    pres = filter_output.css('pre')
    assert_equal %w(jsx typescript javascript bash json), pres.map { |node| node['data-language'] }
    assert_equal 'const value = 1', pres[0].at_css('code').content
    assert_equal 1, pres[0].css('code').length
    assert_nil pres[0].at_css('.th-token')
    assert_nil filter_output.at_css('button')
    assert_nil filter_output.at_css('.codeblock')
  end
end
