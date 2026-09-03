module Mcp
  # Dispatches a single JSON-RPC 2.0 request (already parsed into a Hash with
  # string keys) to the appropriate MCP handler and returns a response Hash
  # ready to be serialized back to the client.
  module Server
    TOOLS = [
      {
        'name' => 'devdocs_list_docsets',
        'description' => 'List documentation sets available on this DevDocs instance.',
        'inputSchema' => { 'type' => 'object', 'properties' => {}, 'additionalProperties' => false },
      },
      {
        'name' => 'devdocs_search',
        'description' => 'Search entry names/paths within one downloaded DevDocs doc set.',
        'inputSchema' => {
          'type' => 'object',
          'properties' => {
            'slug' => { 'type' => 'string' },
            'query' => { 'type' => 'string' },
          },
          'required' => %w(slug query),
          'additionalProperties' => false,
        },
      },
      {
        'name' => 'devdocs_get_page',
        'description' => 'Fetch one entry from a DevDocs doc set as plain text.',
        'inputSchema' => {
          'type' => 'object',
          'properties' => {
            'slug' => { 'type' => 'string' },
            'path' => { 'type' => 'string' },
          },
          'required' => %w(slug path),
          'additionalProperties' => false,
        },
      },
    ].freeze

    def self.handle(request, app_settings)
      case request['method']
      when 'initialize'
        respond(request, {
          'protocolVersion' => '2024-11-05',
          'capabilities' => { 'tools' => {} },
          'serverInfo' => { 'name' => 'devdocs-mcp', 'version' => '1.0.0' },
        })
      when 'tools/list'
        respond(request, { 'tools' => TOOLS })
      when 'tools/call'
        call_tool(request, app_settings)
      else
        error(request, -32601, "Unsupported method: #{request['method']}")
      end
    end

    def self.error(request, code, message)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'error' => { 'code' => code, 'message' => message } }
    end

    def self.call_tool(request, app_settings)
      params = request['params']
      case params['name']
      when 'devdocs_list_docsets'
        docsets = app_settings.docs.values
        as_text_result(request, docsets)
      when 'devdocs_search'
        entries = search_docset(app_settings, params['arguments']['slug'], params['arguments']['query'])
        as_text_result(request, entries)
      when 'devdocs_get_page'
        text = get_page(app_settings, params['arguments']['slug'], params['arguments']['path'])
        respond(request, { 'content' => [{ 'type' => 'text', 'text' => text }] })
      end
    end

    def self.get_page(app_settings, slug, path)
      db_path = File.join(app_settings.docs_path, slug, 'db.json')
      db = JSON.parse(File.read(db_path))
      html = db[path]
      Nokogiri::HTML::DocumentFragment.parse(html).text.squeeze(' ').strip
    end

    def self.search_docset(app_settings, slug, query)
      index_path = File.join(app_settings.docs_path, slug, 'index.json')
      index = JSON.parse(File.read(index_path))
      q = query.downcase
      index['entries'].select { |e| e['name'].downcase.include?(q) || e['path'].downcase.include?(q) }
    end

    def self.as_text_result(request, data)
      respond(request, { 'content' => [{ 'type' => 'text', 'text' => data.to_json }] })
    end

    def self.respond(request, result)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => result }
    end
  end
end
