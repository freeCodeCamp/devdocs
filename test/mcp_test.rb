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

  describe 'POST /mcp' do
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

    it 'calls devdocs_list_docsets and returns the configured doc sets' do
      result = rpc('tools/call', { 'name' => 'devdocs_list_docsets', 'arguments' => {} })['result']
      docsets = JSON.parse(result['content'].first['text'])
      slugs = docsets.map { |d| d['slug'] }
      assert_includes slugs, 'css'
      assert_includes slugs, 'html~5'
    end

    it 'calls devdocs_search and returns matching entries for a doc set' do
      args = { 'slug' => 'mcp_fixture', 'query' => 'push' }
      result = rpc('tools/call', { 'name' => 'devdocs_search', 'arguments' => args })['result']
      entries = JSON.parse(result['content'].first['text'])
      assert_equal 1, entries.length
      assert_equal 'array/push', entries.first['path']
    end

    it 'calls devdocs_get_page and returns the entry as plain text' do
      args = { 'slug' => 'mcp_fixture', 'path' => 'array/push' }
      result = rpc('tools/call', { 'name' => 'devdocs_get_page', 'arguments' => args })['result']
      text = result['content'].first['text']
      assert_includes text, 'Array#push'
      assert_includes text, 'Appends & returns the array.'
      refute_includes text, '<h1>'
    end

    it 'returns a JSON-RPC error for an unsupported method' do
      response = rpc('not/a/real/method')
      assert_equal(-32601, response['error']['code'])
    end
  end
end
