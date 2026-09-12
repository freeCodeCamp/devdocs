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
        'description' => 'Search entry names/paths within one downloaded DevDocs doc set. Returns paginated results.',
        'inputSchema' => {
          'type' => 'object',
          'properties' => {
            'slug' => { 'type' => 'string' },
            'query' => { 'type' => 'string', 'description' => 'Non-empty search query' },
            'offset' => { 'type' => 'integer', 'description' => 'Number of results to skip (default: 0)', 'minimum' => 0 },
            'limit' => { 'type' => 'integer', 'description' => 'Maximum results to return (default: 50, max: 500)', 'minimum' => 1, 'maximum' => 500 },
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
    rescue => err
      error(request, -32603, "Internal error: #{err.message}")
    end

    def self.error(request, code, message)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'error' => { 'code' => code, 'message' => message } }
    end

    def self.call_tool(request, app_settings)
      params = request['params']
      tool_name = params['name']
      arguments = params['arguments'] || {}

      tool_def = TOOLS.find { |t| t['name'] == tool_name }
      unless tool_def
        return error(request, -32602, "Unknown tool: #{tool_name}")
      end

      validation_error = validate_arguments(arguments, tool_def['inputSchema'])
      if validation_error
        return error(request, -32602, validation_error)
      end

      case tool_name
      when 'devdocs_list_docsets'
        result = list_docsets(app_settings, arguments)
        as_text_result(request, result)
      when 'devdocs_search'
        slug = arguments['slug']
        query = arguments['query']
        begin
          result = search_docset(app_settings, slug, query, arguments)
          as_text_result(request, result)
        rescue => err
          error(request, -32603, "Search failed: #{err.message}")
        end
      when 'devdocs_get_page'
        slug = arguments['slug']
        path = arguments['path']
        begin
          text = get_page(app_settings, slug, path)
          respond(request, { 'content' => [{ 'type' => 'text', 'text' => text }] })
        rescue => err
          error(request, -32603, "Page retrieval failed: #{err.message}")
        end
      end
    end

    def self.validate_arguments(arguments, schema)
      required = schema['required'] || []
      properties = schema['properties'] || {}

      required.each do |field|
        return "Missing required field: #{field}" unless arguments.key?(field)
      end

      arguments.each do |field, value|
        return "Unknown field: #{field}" unless properties.key?(field)
        prop_schema = properties[field]
        error_msg = validate_value(value, prop_schema)
        return error_msg if error_msg
      end

      return "Additional properties not allowed" if schema['additionalProperties'] == false && arguments.keys.any? { |k| !properties.key?(k) }

      nil
    end

    def self.validate_value(value, schema)
      type = schema['type']

      case type
      when 'string'
        return "Expected string, got #{value.class}" unless value.is_a?(String)
      when 'integer'
        return "Expected integer, got #{value.class}" unless value.is_a?(Integer)
      when 'number'
        return "Expected number, got #{value.class}" unless value.is_a?(Numeric)
      end

      if schema['minimum'] && value < schema['minimum']
        return "Value #{value} is below minimum #{schema['minimum']}"
      end
      if schema['maximum'] && value > schema['maximum']
        return "Value #{value} exceeds maximum #{schema['maximum']}"
      end

      nil
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
      html_to_text(html)
    end

    def self.html_to_text(html)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      text_parts = []

      doc.traverse do |node|
        if node.text?
          text_parts << node.text
        elsif block_element?(node.name)
          text_parts << "\n" if text_parts.last != "\n"
        end
      end

      text_parts.join.squeeze(' ').gsub(/\n\s*\n/, "\n").strip
    end

    def self.block_element?(tag_name)
      return false unless tag_name
      %w(p div h1 h2 h3 h4 h5 h6 ul ol li blockquote pre br).include?(tag_name.downcase)
    end

    def self.search_docset(app_settings, slug, query, args = {})
      raise "Query cannot be empty" if query.to_s.strip.empty?

      validate_slug(app_settings, slug)
      index_path = File.join(app_settings.docs_path, slug, 'index.json')
      unless File.exist?(index_path)
        raise "Search index not available for #{slug}. The search index is served from the CDN."
      end

      offset = (args['offset'] || 0).to_i
      limit = [(args['limit'] || 50).to_i, 500].min

      index = JSON.parse(File.read(index_path))
      query_lower = query.downcase

      all_matches = index['entries'].select do |entry|
        entry['name'].downcase.include?(query_lower) || entry['path'].downcase.include?(query_lower)
      end

      total_count = all_matches.length
      paginated = all_matches.drop(offset).take(limit)

      {
        'entries' => paginated,
        'offset' => offset,
        'limit' => limit,
        'total' => total_count,
        'returned' => paginated.length,
      }
    end

    def self.as_text_result(request, data)
      respond(request, { 'content' => [{ 'type' => 'text', 'text' => data.to_json }] })
    end

    def self.respond(request, result)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => result }
    end
  end
end
