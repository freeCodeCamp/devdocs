require 'test_helper'
require 'rack/test'
require 'app'

class McpTest < Minitest::Spec
  include Rack::Test::Methods

  def app
    App
  end

  before do
    current_session.env('HTTPS', 'on')
  end

  def rpc(method, params = nil, id: 1)
    body = { jsonrpc: '2.0', id: id, method: method }
    body[:params] = params if params
    post '/mcp', body.to_json, 'CONTENT_TYPE' => 'application/json'
    JSON.parse(last_response.body)
  end

  def notify(method, params = nil)
    body = { jsonrpc: '2.0', method: method }
    body[:params] = params if params
    post '/mcp', body.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'POST /mcp' do
    it 'accepts notifications without answering them' do
      notify('notifications/initialized')
      assert_equal 202, last_response.status
      assert_empty last_response.body
    end

    it 'does not answer a notification for an unknown method' do
      notify('notifications/cancelled', { 'requestId' => 1 })
      assert_equal 202, last_response.status
      assert_empty last_response.body
    end

    it 'answers a request whose id is null' do
      response = rpc('tools/list', nil, id: nil)
      assert_nil response['id']
      assert response['result'].key?('tools')
    end

    it 'responds to initialize with protocol info' do
      result = rpc('initialize')['result']
      assert_equal '2024-11-05', result['protocolVersion']
      assert result['capabilities'].key?('tools')
    end

    it 'lists the devdocs tools' do
      tools = rpc('tools/list')['result']['tools']
      names = tools.map { |t| t['name'] }
      assert_includes names, 'devdocs_list_docsets'
      assert_includes names, 'devdocs_search'
      assert_includes names, 'devdocs_get_page'
    end

    it 'calls devdocs_list_docsets and returns paginated docsets in condensed format' do
      result = rpc('tools/call', { 'name' => 'devdocs_list_docsets', 'arguments' => {} })['result']
      response = JSON.parse(result['content'].first['text'])

      assert response.key?('docsets')
      assert response.key?('offset')
      assert response.key?('limit')
      assert response.key?('total')
      assert response.key?('returned')

      docsets = response['docsets']
      assert docsets.length > 0
      first = docsets.first
      assert first.key?('slug')
      assert first.key?('name')
      assert first.key?('version')
      refute first.key?('release_date'), 'should not include release_date'
      refute first.key?('mtime'), 'should not include mtime'

      slugs = docsets.map { |d| d['slug'] }
      assert_includes slugs, 'css'
      assert_includes slugs, 'html~5'
    end

    it 'paginates results with offset and limit' do
      result = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'offset' => 0, 'limit' => 2 }
      })['result']
      response = JSON.parse(result['content'].first['text'])

      assert_equal 0, response['offset']
      assert_equal 2, response['limit']
      assert_equal 2, response['returned']
      assert response['total'] > 2
      assert_equal 2, response['docsets'].length
    end

    it 'respects offset to skip results' do
      first_page = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'offset' => 0, 'limit' => 2 }
      })['result']
      first_docsets = JSON.parse(first_page['content'].first['text'])['docsets'].map { |d| d['slug'] }

      second_page = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'offset' => 2, 'limit' => 2 }
      })['result']
      second_docsets = JSON.parse(second_page['content'].first['text'])['docsets'].map { |d| d['slug'] }

      assert first_docsets != second_docsets
    end

    it 'filters docsets by query string' do
      result = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'query' => 'css' }
      })['result']
      response = JSON.parse(result['content'].first['text'])

      docsets = response['docsets']
      assert docsets.length > 0
      assert docsets.all? { |d| d['slug'].downcase.include?('css') || d['name'].downcase.include?('css') }
    end

    it 'filters case-insensitively' do
      result = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'query' => 'CSS' }
      })['result']
      response = JSON.parse(result['content'].first['text'])

      docsets = response['docsets']
      assert docsets.length > 0
      assert docsets.any? { |d| d['slug'] == 'css' }
    end

    it 'returns empty docsets for non-matching query' do
      result = rpc('tools/call', {
        'name' => 'devdocs_list_docsets',
        'arguments' => { 'query' => 'nonexistentdocthing' }
      })['result']
      response = JSON.parse(result['content'].first['text'])

      assert_equal 0, response['returned']
      assert_equal [], response['docsets']
      assert response['total'] == 0
    end

    it 'calls devdocs_search and returns paginated matching entries' do
      args = { 'slug' => 'mcp_fixture', 'query' => 'push' }
      result = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })['result']
      response = JSON.parse(result['content'].first['text'])

      assert response.key?('entries')
      assert response.key?('offset')
      assert response.key?('limit')
      assert response.key?('total')
      assert response.key?('returned')

      entries = response['entries']
      assert_equal 1, entries.length
      assert_equal 'array/push', entries.first['path']
    end

    it 'returns error for empty search query' do
      args = { 'slug' => 'mcp_fixture', 'query' => '' }
      response = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })
      assert response.key?('error')
      assert_equal(-32603, response['error']['code'])
      assert_includes response['error']['message'].downcase, 'empty'
    end

    it 'paginates search results with offset and limit' do
      result = rpc('tools/call', {
        'name' => 'devdocs_search',
        'arguments' => { 'slug' => 'mcp_fixture', 'query' => 'a', 'offset' => 0, 'limit' => 1 }
      })['result']
      response = JSON.parse(result['content'].first['text'])

      assert_equal 0, response['offset']
      assert_equal 1, response['limit']
      assert response['total'] > 0
      assert_equal 1, response['returned']
    end

    it 'calls devdocs_get_page and returns the entry as plain text' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/push' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      text = result['content'].first['text']
      assert_includes text, 'Array#push'
      assert_includes text, 'Appends & returns the array.'
      refute_includes text, '<h1>'
    end

    it 'strips the fragment from the path when looking up the page' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/pop#shift' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      assert_includes result['content'].first['text'], 'Removes the last element.'
    end

    it 'separates table cells and definition lists in the extracted text' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/table' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      text = result['content'].first['text']
      refute_includes text, 'NameType'
      refute_includes text, 'fooString'
      refute_includes text, 'barA thing.'
    end

    it 'separates text preceding a block element from the block' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/blocks' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      assert_equal "Options are:\none\ntwo", result['content'].first['text']
    end

    it 'keeps the indentation of preformatted code' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/code' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      assert_includes result['content'].first['text'], "def push(x)\n  items << x\nend"
    end

    it 'picks up a re-scraped search index' do
      index_path = File.join(App.docs_path, 'mcp_fixture', 'index.json')
      original = File.read(index_path)
      args = { 'slug' => 'mcp_fixture', 'query' => 'upcase' }
      begin
        first = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })['result']
        assert_equal 1, JSON.parse(first['content'].first['text'])['total']

        File.write(index_path, JSON.generate('entries' => [], 'types' => []))
        second = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })['result']
        assert_equal 0, JSON.parse(second['content'].first['text'])['total']
      ensure
        File.write(index_path, original)
      end
    end

    it 'returns error for invalid slug in search (path traversal protection)' do
      args = { 'slug' => '../../../etc/passwd', 'query' => 'test' }
      response = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })
      assert response.key?('error'), 'should return an error for invalid slug'
      assert_equal(-32603, response['error']['code'])
      assert_includes response['error']['message'], 'Invalid docset slug'
    end

    it 'returns error for invalid slug in get_page (path traversal protection)' do
      args = { 'slug' => '..\\windows\\system32', 'path' => '/test' }
      response = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })
      assert response.key?('error'), 'should return an error for invalid slug'
      assert_equal(-32603, response['error']['code'])
      assert_includes response['error']['message'], 'Invalid docset slug'
    end

    it 'returns error for missing search index in devdocs_search' do
      args = { 'slug' => 'css', 'query' => 'test' }
      response = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })
      if response.key?('error')
        assert_equal(-32603, response['error']['code'])
        assert_includes response['error']['message'].downcase, 'search index'
      end
    end

    it 'returns error for a docset whose pages are not downloaded' do
      args = { 'slug' => 'css', 'path' => '/test' }
      response = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })
      assert_equal(-32603, response['error']['code'])
      assert_includes response['error']['message'].downcase, 'not available'
    end

    it 'returns error for a page path escaping the docset' do
      args = { 'slug' => 'mcp_fixture', 'path' => '../../../etc/passwd' }
      response = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })
      assert_equal(-32603, response['error']['code'])
      assert_includes response['error']['message'], 'Page not found'
    end

    it 'returns error for missing required arguments' do
      args = { 'slug' => 'mcp_fixture' }
      response = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })
      assert response.key?('error')
      assert_equal(-32602, response['error']['code'])
      assert_includes response['error']['message'], 'query'
    end

    it 'returns error for invalid argument types' do
      args = { 'slug' => 'mcp_fixture', 'query' => 123 }
      response = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })
      assert response.key?('error')
      assert_equal(-32602, response['error']['code'])
      assert_includes response['error']['message'].downcase, 'string'
    end

    it 'returns error for invalid parameter values' do
      args = { 'offset' => 0, 'limit' => 1000 }
      response = rpc('tools/call', { 'name' => 'devdocs_list_docsets', 'arguments' => args })
      assert response.key?('error')
      assert_equal(-32602, response['error']['code'])
      assert_includes response['error']['message'], 'exceeds maximum'
    end

    it 'returns JSON-RPC error for malformed JSON' do
      post '/mcp', '{invalid json}', 'CONTENT_TYPE' => 'application/json'
      response = JSON.parse(last_response.body)
      assert response.key?('error')
      assert_equal(-32700, response['error']['code'])
      assert_includes response['error']['message'].downcase, 'parse'
    end

    it 'returns an invalid params error for tools/call without params' do
      response = rpc('tools/call')
      assert_equal(-32602, response['error']['code'])
      refute_includes response['error']['message'], 'undefined method'
    end

    it 'returns an invalid params error for non-object arguments' do
      response = rpc('tools/call', { 'name' => 'devdocs_list_docsets', 'arguments' => [] })
      assert_equal(-32602, response['error']['code'])
      assert_includes response['error']['message'], 'arguments'
    end

    it 'returns an invalid request error for a batch' do
      post '/mcp', [{ jsonrpc: '2.0', id: 1, method: 'tools/list' }].to_json, 'CONTENT_TYPE' => 'application/json'
      response = JSON.parse(last_response.body)
      assert_equal(-32600, response['error']['code'])
      assert_nil response['id']
      assert_includes response['error']['message'].downcase, 'batch'
    end

    it 'returns an invalid request error for a non-object payload' do
      post '/mcp', '42', 'CONTENT_TYPE' => 'application/json'
      response = JSON.parse(last_response.body)
      assert_equal(-32600, response['error']['code'])
      assert_nil response['id']
    end

    it 'returns a JSON-RPC error for an unsupported method' do
      response = rpc('not/a/real/method')
      assert_equal(-32601, response['error']['code'])
    end
  end
end
