module Mcp
  # Dispatches a single JSON-RPC 2.0 request (already parsed into a Hash with
  # string keys) to the appropriate MCP handler and returns a response Hash
  # ready to be serialized back to the client.
  module Server
    TOOLS = [
      {
        'name' => 'devdocs_list_docsets',
        'description' => 'List documentation sets available on this DevDocs instance. Returns paginated results with optional filtering.',
        'inputSchema' => {
          'type' => 'object',
          'properties' => {
            'offset' => { 'type' => 'integer', 'description' => 'Number of results to skip (default: 0)', 'minimum' => 0 },
            'limit' => { 'type' => 'integer', 'description' => 'Maximum results to return (default: 50, max: 500)', 'minimum' => 1, 'maximum' => 500 },
            'query' => { 'type' => 'string', 'description' => 'Filter by slug or name (case-insensitive substring match)' },
          },
          'additionalProperties' => false,
        },
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
        result = list_docsets(app_settings, params['arguments'] || {})
        as_text_result(request, result)
      when 'devdocs_search'
        slug = params['arguments']['slug']
        query = params['arguments']['query']
        begin
          entries = search_docset(app_settings, slug, query)
          as_text_result(request, entries)
        rescue => err
          error(request, -32603, "Search failed: #{err.message}")
        end
      when 'devdocs_get_page'
        slug = params['arguments']['slug']
        path = params['arguments']['path']
        begin
          text = get_page(app_settings, slug, path)
          respond(request, { 'content' => [{ 'type' => 'text', 'text' => text }] })
        rescue => err
          error(request, -32603, "Page retrieval failed: #{err.message}")
        end
      end
    end

    def self.list_docsets(app_settings, args)
      offset = (args['offset'] || 0).to_i
      limit = [(args['limit'] || 50).to_i, 500].min
      query = args['query']&.downcase

      all_docsets = app_settings.docs.values.map do |docset|
        {
          'slug' => docset['slug'],
          'name' => docset['name'],
          'version' => docset['version'],
        }
      end

      filtered = if query
        all_docsets.select do |docset|
          docset['slug'].downcase.include?(query) || docset['name'].downcase.include?(query)
        end
      else
        all_docsets
      end

      total_count = filtered.length
      paginated = filtered.drop(offset).take(limit)

      {
        'docsets' => paginated,
        'offset' => offset,
        'limit' => limit,
        'total' => total_count,
        'returned' => paginated.length,
      }
    end

    def self.validate_slug(app_settings, slug)
      unless app_settings.docs.key?(slug)
        raise ArgumentError, "Invalid docset slug: #{slug}"
      end
      slug
    end

    def self.get_page(app_settings, slug, path)
      validate_slug(app_settings, slug)
      db_path = File.join(app_settings.docs_path, slug, 'db.json')
      unless File.exist?(db_path)
        raise "Page database not available for #{slug}. Full content is served from the CDN."
      end
      db = JSON.parse(File.read(db_path))
      html = db[path]
      raise "Page not found: #{path}" unless html
      Nokogiri::HTML::DocumentFragment.parse(html).text.squeeze(' ').strip
    end

    def self.search_docset(app_settings, slug, query)
      validate_slug(app_settings, slug)
      index_path = File.join(app_settings.docs_path, slug, 'index.json')
      unless File.exist?(index_path)
        raise "Search index not available for #{slug}. The search index is served from the CDN."
      end
      index = JSON.parse(File.read(index_path))
      query_lower = query.downcase
      index['entries'].select do |entry|
        entry['name'].downcase.include?(query_lower) || entry['path'].downcase.include?(query_lower)
      end
    end

    def self.as_text_result(request, data)
      respond(request, { 'content' => [{ 'type' => 'text', 'text' => data.to_json }] })
    end

    def self.respond(request, result)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => result }
    end
  end
end
