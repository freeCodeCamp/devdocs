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

        if json
          if json.is_a?(Array)
            json.each do |element|

              if element['version_added']
                version_added.push(element['version_added'])
              else
                version_added.push(false)
              end

              if element['version_removed']
                version_removed.push(element['version_removed'])
              else
                version_removed.push(false)
              end

              if element['notes']
                notes.push(element['notes'])
              else
                notes.push(false)
              end

            end
          else
            version_added.push(json['version_added'])
            version_removed.push(json['version_removed'])
            notes.push(json['notes'])
          end

          version_added.map! do |version|
            if version == true
              'Yes'
            elsif version == false
              'No'
            elsif version.is_a?(String)
              version
            else
              '?'
            end
          end

          if version_removed[0]
            format_string = "<td class=bc-supports-no>"
          elsif version_added[0] == 'No'
            format_string = "<td class=bc-supports-no>"
          elsif version_added[0] == '?'
            format_string = "<td class=bc-supports-unknown>"
          else
            format_string = "<td class=bc-supports-yes>"
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

        else
          format_string = "<td class=bc-supports-unknown><div>?</div></td>"
        end

        entry.add_child(format_string)
      end

    end
  end
end
