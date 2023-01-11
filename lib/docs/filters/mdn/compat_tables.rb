module Docs
  class Mdn
    class CompatTablesFilter < Filter

      # Generate browser compatibility table
      # Fixes "BCD tables only load in the browser"
      # https://github.com/mdn/browser-compat-data
      # https://github.com/mdn/yari/tree/main/client/src/document/ingredients/browser-compatibility-table

      def call
        if at_css('#browser_compatibility') \
          and not at_css('#browser_compatibility').next_sibling.classes.include?('warning') \
          and not at_css('#browser_compatibility').next_sibling.content.match?('Supported')

          at_css('#browser_compatibility').next_sibling.remove

          compatibility_tables = generate_compatibility_table()
          compatibility_tables.each do |table|
            at_css('#browser_compatibility').add_next_sibling(table)
          end
        end

        doc
      end

      BROWSERS = {
        'chrome' => 'Chrome',
        'edge' => 'Edge',
        'firefox' => 'Firefox',
        'ie' => 'Internet Explorer',
        'opera' => 'Opera',
        'safari' => 'Safari',
        'webview_android' => 'WebView Android',
        'chrome_android' => 'Chrome Android',
        'firefox_android' => 'Firefox for Android',
        'opera_android' => 'Opera Android',
        'safari_ios' => 'Safari on IOS',
        'samsunginternet_android' => 'Samsung Internet'
      }

      def is_javascript
        current_url.to_s.start_with?('https://developer.mozilla.org/en-US/docs/Web/JavaScript')
      end

      def browsers
        if is_javascript
          {}.merge(BROWSERS).merge({'deno' => 'Deno', 'nodejs' => 'Node.js'})
        else
          BROWSERS
        end
      end

      def browser_types
        if is_javascript
          {'Desktop'=>6, 'Mobile'=>6, 'Server'=>2,}
        else
          {'Desktop'=>6, 'Mobile'=>6,}
        end
      end

      def generate_compatibility_table()
        json_files_uri = request_bcd_uris()

        compat_tables = []

        json_files_uri.each do |uri|
          compat_tables.push(generate_compatibility_table_wrapper(uri))
        end

        return compat_tables
      end

      def request_bcd_uris
        url = current_url.to_s + '/index.json'
        response = Request.run url
        index_json = JSON.load response.body

        uris = []

        index_json['doc']['body'].each do |element|
          uris.push(element['value']['dataURL']) if element['type'] == 'browser_compatibility' and element['value']['dataURL']
        end

        uris.map! do |uri|
          tmp_uri = URI.parse(base_url.to_s)
          tmp_uri.path = uri
          uri = tmp_uri.to_s
        end

        return uris
      end

      def generate_compatibility_table_wrapper(url)
        response = Request.run url
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
          else
            if version_added[0] == 'No'
              format_string = "<td class=bc-supports-no>"
            elsif version_added[0] == '?'
              format_string = "<td class=bc-supports-unknown>"
            else
              format_string = "<td class=bc-supports-yes>"
            end
          end

          for value in (0..version_added.length-1) do
            if version_removed[value]
              format_string += "<div>#{version_added[value]}-#{version_removed[value]}</div>"
            else
              if version_added[value] == 'No'
                format_string += "<div>#{version_added[value]}</div>"
              else
                format_string += "<div>#{version_added[value]}</div>"
              end
            end

            if notes[value]
              format_string += "<div>#{notes[value]}</div>"
            end
          end

        else
          format_string = "<td class=bc-supports-unknown><div>?</div></td>"
        end

        entry.add_child(format_string)
      end

    end
  end
end
