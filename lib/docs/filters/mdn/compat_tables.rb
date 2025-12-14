module Docs
  class Mdn
    class CompatTablesFilter < Filter

      # Generate browser compatibility table
      # Fixes "BCD tables only load in the browser"
      # https://github.com/mdn/browser-compat-data
      # https://github.com/mdn/yari/tree/main/client/src/lit/compat

      def call
        generate_compatibility_table()

        doc
      end

      BROWSERS_DESKTOP = {
        # Desktop
        'chrome' => 'Chrome',
        'edge' => 'Edge',
        'firefox' => 'Firefox',
        'opera' => 'Opera',
        'safari' => 'Safari',
      }
      BROWSERS_MOBILE = {
        # Mobile
        'chrome_android' => 'Chrome Android',
        'firefox_android' => 'Firefox for Android',
        'opera_android' => 'Opera Android',
        'safari_ios' => 'Safari on IOS',
        'samsunginternet_android' => 'Samsung Internet',
        'webview_android' => 'WebView Android',
        'webview_ios' => 'WebView on iOS',
      }
      BROWSERS_SERVER = {
        # Server
        'bun' => 'Bun',
        'deno' => 'Deno',
        'nodejs' => 'Node.js',
      }

      def is_javascript
        current_url.to_s.start_with?('https://developer.mozilla.org/en-US/docs/Web/JavaScript')
      end

      def browsers
        if is_javascript
          {}.merge(BROWSERS_DESKTOP).merge(BROWSERS_MOBILE).merge(BROWSERS_SERVER)
        else
          {}.merge(BROWSERS_DESKTOP).merge(BROWSERS_MOBILE)
        end
      end

      def browser_types
        if is_javascript
          {'Desktop'=>BROWSERS_DESKTOP.length, 'Mobile'=>BROWSERS_MOBILE.length, 'Server'=>BROWSERS_SERVER.length,}
        else
          {'Desktop'=>BROWSERS_DESKTOP.length, 'Mobile'=>BROWSERS_MOBILE.length,}
        end
      end

      def generate_compatibility_table()
        css('mdn-compat-table-lazy').each do |node|
          file = node.attr('query')
          # https://github.com/mdn/browser-compat-data/blob/main/javascript/builtins/Set.json
          # https://bcd.developer.mozilla.org/bcd/api/v0/current/javascript.builtins.Set.json
          uri = "https://bcd.developer.mozilla.org/bcd/api/v0/current/#{file}.json"
          node.replace generate_compatibility_table_wrapper(uri)
        end
      end

      def generate_compatibility_table_wrapper(url)
        response = Request.run url
        return "" unless response.success?
        @json_data = JSON.load(response.body)['data']

        html_table = generate_basic_html_table()

        @json_data.keys.each do |key|
          if key == '__compat' or @json_data[key]['__compat']
            add_entry_to_table(html_table, key)
          else
          end
        end

        return html_table
      end

      def generate_basic_html_table
        table = Nokogiri::XML::Node.new('table', doc.document)

        table.add_child('<thead><tr id=bct-browser-type><tr id=bct-browsers><tbody>')

        table.css('#bct-browser-type').each do |node|
          node.add_child('<th>')
          browser_types.each do |browser_type, colspan|
            node.add_child("<th colspan=#{colspan}>#{browser_type}")
          end
        end

        table.css('#bct-browsers').each do |node|
          node.add_child('<th>')

          browsers.values.each do |browser|
            node.add_child("<th>#{browser}")
          end
        end

        return table
      end

      def add_entry_to_table(html_table, key)
        json = @json_data[key]

        html_table.at_css('tbody').add_child('<tr>')

        last_table_entry = html_table.at_css('tbody').last_element_child

        if key == '__compat'
          tmp = slug.split('/')
          last_table_entry.add_child("<th><code>#{tmp.last}")
        else
          last_table_entry.add_child("<th><code>#{key}")
        end


        browsers.keys.each do |browser_key|
          if key == '__compat'
            add_data_to_entry(json['support'][browser_key], last_table_entry)
          else
            add_data_to_entry(json['__compat']['support'][browser_key], last_table_entry)
          end

        end
      end

      def add_data_to_entry(json, entry)
        version_added = []
        version_removed = []
        notes = []

        if !json
          format_string = "<td class=bc-supports-unknown><div>?</div></td>"
          entry.add_child(format_string)
          return
        end

        format_string = "<td class=bc-supports-unknown>"
        (json.is_a?(Array) ? json : [json]).each do |element|
          version = element['version_added']
          if version.is_a?(String) and element['release_date']
            format_string = "<td class=bc-supports-yes>"
            format_string = "<td class=bc-supports-preview>" if element['release_date'] > Time.now.iso8601
            version_added.push("<abbr title='Release date: #{element['release_date']}'>#{version}</abbr>")
          elsif version == 'preview'
            format_string = "<td class=bc-supports-preview>"
            version_added.push(version)
          elsif version.is_a?(String)
            format_string = "<td class=bc-supports-yes>"
            version_added.push(version)
          elsif version == true
            format_string = "<td class=bc-supports-yes>"
            version_added.push('Yes')
          else
            format_string = "<td class=bc-supports-no>"
            version_added.push('No')
          end
          version_removed.push(element['version_removed'] || false)
          notes.push(element['notes'] || false)
        end

        for value in (0..version_added.length-1) do
          if version_removed[value]
            version_string = "#{version_added[value]}–#{version_removed[value]}"
          else
            version_string = version_added[value]
          end

          if notes[value]
            format_string += "<details><summary>#{version_string}</summary>#{notes[value]}</details>"
          else
            format_string += "<div>#{version_string}</div>"
          end
        end

        format_string += "</td>"

        entry.add_child(format_string)
      end

    end
  end
end
