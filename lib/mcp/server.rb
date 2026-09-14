module Mcp
  # Dispatches a single JSON-RPC 2.0 request (already parsed into a Hash with
  # string keys) to the appropriate MCP handler and returns a response Hash
  # ready to be serialized back to the client.
  module Server
    INDEX_CACHE = {}
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
      html_to_text(File.read(page_path(app_settings, slug, path)))
    end

    # Resolves an entry path to the file its page is stored in, the same way the
    # client does (Entry#_filePath): entries sharing a page carry a #fragment,
    # and the path leaves out the .html extension. Reading the page beats
    # looking it up in db.json, which would mean parsing up to 100MB of JSON.
    def self.page_path(app_settings, slug, path)
      docset_path = File.expand_path(File.join(app_settings.docs_path, slug))
      unless Dir.exist?(docset_path)
        raise "Pages not available for #{slug}. They are served from the CDN."
      end

      file = path.sub(/#.*/, '')
      file += '.html' unless file.end_with?('.html')
      file_path = File.expand_path(File.join(docset_path, file))

      # The path comes from the caller, so keep it inside the docset.
      unless file_path.start_with?(docset_path + File::SEPARATOR) && File.file?(file_path)
        raise "Page not found: #{path}"
      end
      file_path
    end

    def self.html_to_text(html)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      segments = []
      collect_text(doc, segments, false)
      # Collapse whitespace outside <pre> only; code samples keep their
      # indentation and blank lines verbatim.
      segments.map { |segment|
        segment[:pre] ? segment[:text] : segment[:text].squeeze(' ').gsub(/\n\s*\n/, "\n")
      }.join.strip
    end

    # Walks the tree in document order, wrapping the text of each block element
    # in newlines. Nokogiri's #traverse is post-order, which emitted a block's
    # separator only after its text and ran the text before it into the block.
    # Text is collected into runs of equal preformattedness so that the
    # whitespace collapsing above can skip the preformatted ones.
    def self.collect_text(node, segments, preformatted)
      node.children.each do |child|
        if child.text?
          append_text(segments, child.text, preformatted)
        elsif block_element?(child.name)
          append_text(segments, "\n", preformatted)
          collect_text(child, segments, preformatted || child.name.casecmp('pre').zero?)
          append_text(segments, "\n", preformatted)
        else
          collect_text(child, segments, preformatted)
        end
      end
    end

    def self.append_text(segments, text, preformatted)
      last = segments.last
      if last && last[:pre] == preformatted
        last[:text] << text
      else
        segments << { pre: preformatted, text: +text }
      end
    end

    def self.block_element?(tag_name)
      return false unless tag_name
      %w(p div h1 h2 h3 h4 h5 h6 ul ol li dl dt dd
         table caption thead tbody tfoot tr th td
         blockquote pre br).include?(tag_name.downcase)
    end

    def self.search_docset(app_settings, slug, query, args = {})
      raise "Query cannot be empty" if query.to_s.strip.empty?

      validate_slug(app_settings, slug)

      offset = (args['offset'] || 0).to_i
      limit = [(args['limit'] || 50).to_i, 500].min

      index = load_index(app_settings, slug)
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

    # Caches the parsed index of every docset searched so far. Unlike db.json,
    # the indexes are small (16.5MB for all of the docsets here), and they would
    # otherwise be re-parsed on every search. A re-scraped docset is picked up
    # again by way of the mtime and the size.
    def self.load_index(app_settings, slug)
      index_path = File.join(app_settings.docs_path, slug, 'index.json')
      stat = begin
        File.stat(index_path)
      rescue Errno::ENOENT
        raise "Search index not available for #{slug}. The search index is served from the CDN."
      end

      stamp = [stat.mtime, stat.size]
      cached = INDEX_CACHE[index_path]
      return cached[:index] if cached && cached[:stamp] == stamp

      index = JSON.parse(File.read(index_path))
      INDEX_CACHE[index_path] = { stamp: stamp, index: index }
      index
    end

    def self.as_text_result(request, data)
      respond(request, { 'content' => [{ 'type' => 'text', 'text' => data.to_json }] })
    end

    def self.respond(request, result)
      { 'jsonrpc' => '2.0', 'id' => request['id'], 'result' => result }
    end
  end
end
