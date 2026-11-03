require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

# A page of firebase.google.com/docs, cut down to what the filters look at.
FIREBASE_PAGE = <<~HTML
  <div class="devsite-article-meta nocontent">
    <ul class="devsite-breadcrumb-list">
      <li><a class="devsite-breadcrumb-link" href="/">Firebase</a></li>
      <li><a class="devsite-breadcrumb-link" href="/docs">Documentation</a></li>
      <li><a class="devsite-breadcrumb-link" href="/docs/auth">Authentication</a></li>
    </ul>
  </div>
  <h1 class="devsite-page-title">Get started<devsite-actions><devsite-feature-tooltip class="nocontent">Stay organized</devsite-feature-tooltip></devsite-actions></h1>
  <devsite-toc class="devsite-nav"><a href="#a">On this page</a></devsite-toc>
  <div class="devsite-article-body">
    <section class="firebase-ai-prompt-cards"><pre>Help me use Firebase</pre></section>
    <h2 id="add" data-text="Add" tabindex="-1">Add the <span class="notranslate">Authentication</span> SDK</h2>
    <devsite-selector>
      <section><h3 id="web"><span class="two-line-tab"><span tab-label="modular API">Web</span></span></h3>
        <div class="devsite-github-link nocontent">View on GitHub</div>
        <devsite-code><pre class="devsite-click-to-copy" syntax="Python"><span class="devsite-syntax-kn">import</span> x</pre></devsite-code>
      </section>
    </devsite-selector>
    <div class="ds-selector-tabs">
      <section><h5 id="swift"><devsite-analytics-scope>Swift</devsite-analytics-scope></h5><pre>let x = 1</pre></section>
    </div>
    <devsite-thumb-rating>Was this helpful?</devsite-thumb-rating>
  </div>
HTML

class FirebaseCleanHtmlFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Firebase::CleanHtmlFilter
  self.filter_type = 'html'

  before do
    context[:base_url] = 'https://firebase.google.com/docs/'
    context[:root_url] = 'https://firebase.google.com/docs/'
    context[:url] = 'https://firebase.google.com/docs/auth/web/start'
    @body = FIREBASE_PAGE
  end

  it "keeps the title and the article, without Google's page furniture" do
    html = filter_output_string
    assert html.start_with?('<h1>Get started</h1>')
    %w(Stay\ organized On\ this\ page View\ on\ GitHub Was\ this\ helpful Help\ me\ use devsite-).each do |text|
      refute_includes html, text
    end
    assert_includes html, '<h2 id="add">Add the Authentication SDK</h2>'
  end

  it "labels each tab of a code sample, and colours its code in the tab's language" do
    html = filter_output_string
    assert_includes html, '<p class="_firebase-tab"><strong>Web (modular API)</strong></p>'
    assert_includes html, '<pre data-language="javascript">import x</pre>'
    assert_match %r{<p class="_firebase-tab"><strong>Swift</strong></p>\s*<pre data-language="swift">let x = 1</pre>}, html
  end

  it "titles a landing page without one" do
    context[:url] = 'https://firebase.google.com/docs/'
    @body = '<div class="devsite-article-body"><p>Hi</p></div>'
    assert_equal '<h1>Firebase</h1><p>Hi</p>', filter_output_string
  end
end

class FirebaseEntriesFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Firebase::EntriesFilter
  self.filter_type = 'html'

  before do
    context[:base_url] = 'https://firebase.google.com/docs/'
    context[:root_url] = 'https://firebase.google.com/docs/'
    context[:url] = 'https://firebase.google.com/docs/auth/web/start'
    @body = FIREBASE_PAGE
  end

  it "names the page by its title, and groups it by product" do
    assert_equal 'Get started', filter.name
    assert_equal 'Authentication', filter.type
  end

  it "groups pages without breadcrumbs by the product in their address" do
    context[:url] = 'https://firebase.google.com/docs/firestore/query-data/get-data'
    @body = '<h1 class="devsite-page-title">Get data</h1>'
    assert_equal 'Cloud Firestore', filter.type
  end
end
