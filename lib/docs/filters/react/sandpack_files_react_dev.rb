module Docs
  class React
    # react.dev only renders the active file of a multi-file Sandpack example; the source of
    # every file is in the page's __NEXT_DATA__ script, which clean_html removes.
    class SandpackFilesReactDevFilter < Filter
      LANGUAGES = { 'css' => 'css', 'html' => 'html', 'json' => 'json', 'ts' => 'typescript' }

      def call
        sandpacks = page_sandpacks
        return doc if sandpacks.empty?

        # Pair each rendered example with the next example in the page data that has its tabs and
        # its active file. Recipes and challenges only render their first example, so the data can
        # have more. The first candidate is trusted only while every earlier example matched the
        # very next one and it isn't part of such a group; otherwise all candidates must agree on
        # the files. Unmatched examples keep the rendered file.
        position = 0
        in_step = true
        css('.sandpack--playground').each do |node|
          tabs = node.css('.sp-tab-button')
          active = node.at_css('.sp-tab-button[data-active="true"]')
          pre = node.at_css('pre')
          next in_step = false if tabs.empty? || active.nil? || pre.nil?

          paths = tabs.map { |tab| tab['title'] }
          candidates = (position...sandpacks.length).select do |i|
            files = sandpacks[i][:files]
            paths.all? { |path| files.key?(path) } && same_code?(files[active['title']], pre.content)
          end
          index = candidates.first
          trusted = in_step && index == position && !sandpacks[index][:grouped]
          unless index && (trusted || candidates.map { |i| sandpacks[i][:files].values_at(*paths) }.uniq.one?)
            next in_step = false
          end

          in_step &&= index == position
          position = index + 1
          files = sandpacks[index][:files]
          node.replace(tabs.map { |tab| file_html(tab.content.strip, files[tab['title']]) }.join)
        end

        doc
      end

      private

      def page_sandpacks
        script = at_css('script#__NEXT_DATA__')
        return [] unless script

        content = JSON.parse(script.content).dig('props', 'pageProps', 'content')
        return [] unless content.is_a?(String)

        sandpacks = []
        collect_sandpacks(JSON.parse(content), sandpacks)
        sandpacks
      rescue JSON::ParserError
        []
      end

      # The content is a serialized React tree: elements are ["$r", type, key, props].
      def collect_sandpacks(node, sandpacks, grouped = false)
        if node.is_a?(Array) && node.length == 4 && node[0] == '$r'
          if node[1] == 'Sandpack'
            sandpacks << { files: sandpack_files(node[3]['children']), grouped: grouped }
          else
            collect_sandpacks(node[3], sandpacks, grouped || %w(Recipes Challenges).include?(node[1]))
          end
        elsif node.is_a?(Array)
          node.each { |child| collect_sandpacks(child, sandpacks, grouped) }
        elsif node.is_a?(Hash)
          node.each_value { |child| collect_sandpacks(child, sandpacks, grouped) }
        end
      end

      # Same file paths as react.dev's createFileMap.
      def sandpack_files(children)
        children = [children] unless children.is_a?(Array) && children[0].is_a?(Array)
        children.each_with_object({}) do |child, files|
          next unless child.is_a?(Array) && child[1] == 'pre'
          props = child.dig(3, 'children', 3)
          next unless props.is_a?(Hash)

          language = props['className'].to_s.delete_prefix('language-')
          name = props['meta'].to_s.split.find { |token| token.include?('/') || token.include?('.') }
          path = name ? "/#{name.delete_prefix('/')}" : { 'js' => '/src/App.js', 'css' => '/src/styles.css' }[language]
          files[path] = { code: props['children'].to_s, language: language } if path
        end
      end

      def file_html(label, file)
        %(<div class="_pre-heading">#{CGI.escapeHTML(label)}</div>) +
          %(<pre data-language="#{LANGUAGES.fetch(file[:language], 'jsx')}">#{CGI.escapeHTML(file[:code])}</pre>)
      end

      def same_code?(file, rendered)
        return true if file[:code].gsub(/\s+/, '') == rendered.gsub(/\s+/, '')
        return false unless file[:language] == 'json'

        # Sandpack adds an empty "devDependencies" to the package.json it renders.
        source, shown = JSON.parse(file[:code]), JSON.parse(rendered)
        return false unless source.is_a?(Hash) && shown.is_a?(Hash)
        shown.delete('devDependencies') if shown['devDependencies'] == {} && !source.key?('devDependencies')
        source == shown
      rescue JSON::ParserError
        false
      end
    end
  end
end
