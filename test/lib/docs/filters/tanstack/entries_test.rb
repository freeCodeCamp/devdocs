require_relative '../../../../test_helper'
require_relative '../../../../../lib/docs'

class TanstackEntriesFilterTest < Minitest::Spec
  include FilterTestHelper
  self.filter_class = Docs::Tanstack::EntriesFilter

  def page(path, root_path, body)
    context[:base_url] = 'https://tanstack.com/query/latest/docs/'
    context[:root_url] = "https://tanstack.com/query/latest/docs/#{root_path}"
    context[:root_path] = root_path
    context[:url] = "https://tanstack.com/query/latest/docs/#{path}"
    result[:path] = path == root_path ? 'index' : path
    @body = body
    @filter = nil
    @filter_output = nil
    @filter_result = nil
  end

  def entries
    filter_result[:entries]
  end

  it 'files a React reference page as one Functions entry' do
    page 'framework/react/reference/functions/useQuery', 'framework/react/overview', <<-HTML
      <h1>useQuery</h1>
      <div class="prose">
        <h2 id="overview">Overview<a class="anchor-heading-link" href="#overview">#</a></h2>
        <h2 id="parameters">Parameters#</h2>
        <h3 id="returns">Returns</h3>
      </div>
      <footer><h2>Libraries</h2></footer>
    HTML

    assert_equal 1, entries.length
    assert_equal 'useQuery', entries.first.name
    assert_equal 'Functions', entries.first.type
  end

  it 'names the reference index API Reference' do
    page 'framework/react/reference/index', 'framework/react/overview', '<h1>@tanstack/react-query</h1><div class="prose"></div>'

    assert_equal 'API Reference', entries.first.name
    assert_equal 'API Reference', entries.first.type
  end

  it 'prefixes guide headings and skips Further Reading' do
    page 'framework/react/guides/queries', 'framework/react/overview', <<-HTML
      <h1>Queries</h1>
      <div class="prose">
        <h2 id="query-basics">Query Basics<a class="anchor-heading-link" href="#query-basics">#</a></h2>
        <h2 id="further-reading">Further Reading<a class="anchor-heading-link" href="#further-reading">#</a></h2>
      </div>
      <h2>Libraries</h2>
    HTML

    assert_equal ['Queries', 'Queries: Query Basics'], entries.map(&:name)
    assert_equal 'framework/react/guides/queries#query-basics', entries.last.path
    assert entries.all? { |entry| entry.type == 'Guides' }
  end

  it 'files a flat v4 reference path under API' do
    page 'framework/react/reference/useQuery', 'framework/react/overview', '<h1>useQuery</h1><div class="prose"></div>'

    assert_equal 'useQuery', entries.first.name
    assert_equal 'API', entries.first.type
  end

  it 'derives a Router symbol kind from the h1' do
    page 'api/router/useCanGoBack', 'overview', '<h1>useCanGoBack hook</h1><div class="prose"><h2 id="examples">Examples</h2></div>'
    assert_equal 'useCanGoBack', entries.first.name
    assert_equal 'Hooks', entries.first.type
    assert_equal 1, entries.length

    @body = '<h1>useNavigate hook</h1><div class="prose"></div>'
    context[:url] = 'https://tanstack.com/query/latest/docs/api/router/useNavigateHook'
    result[:path] = 'api/router/useNavigateHook'
    @filter = nil
    @filter_output = nil
    @filter_result = nil
    assert_equal 'useNavigate', entries.first.name
    assert_equal 'Hooks', entries.first.type
  end

  it 'keeps a symbol whose last word is not a kind under API' do
    page 'api/router/linkOptions', 'overview', '<h1>Link options</h1><div class="prose"></div>'

    assert_equal 'Link options', entries.first.name
    assert_equal 'API', entries.first.type
  end

  it 'files Router how-to pages under How-to' do
    page 'how-to/setup-authentication', 'overview', '<h1>How to Set Up Basic Authentication and Protected Routes</h1><div class="prose"></div>'

    assert_equal 'How to Set Up Basic Authentication and Protected Routes', entries.first.name
    assert_equal 'How-to', entries.first.type
  end
end
