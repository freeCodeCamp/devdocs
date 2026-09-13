module Docs
  class Kotlin
    class CleanHtmlV2Filter < CleanHtmlFilter
      PLATFORMS = {
        'common' => 'Common',
        'js' => 'JS',
        'jvm' => 'JVM',
        'native' => 'Native',
        'wasm-js' => 'Wasm-JS',
        'wasm-wasi' => 'Wasm-WASI'
      }

      SINCE = /Since Kotlin\s*/

      def api_page
        css('.navigation-controls, .feedback-wrapper, .filtered-message, .platform-bookmarks-row, .tabs-section, .anchor-wrapper, .copy-popup-wrapper, .source-link-wrapper').remove
        css('[data-filterable-current]').each { |node| node.remove_attribute('data-filterable-current') }
        css('[data-filterable-set]').each { |node| node.remove_attribute('data-filterable-set') }

        collapse_platform_tabs

        heading = at_css('h1, h2')
        heading.name = 'h1' unless heading.nil?

        if (breadcrumbs = at_css('.breadcrumbs'))
          breadcrumbs.content.blank? ? breadcrumbs.remove : heading&.after(breadcrumbs)
        end

        css('.symbol.monospace').each do |node|
          node.name = 'pre'
          node.remove_attribute('class')
          node['data-language'] = 'kotlin'
          node.inner_html = node.inner_html.strip
        end

        css('.tableheader').each { |node| node.remove_attribute('class') }
      end

      private

      # Dokka 2 repeats every declaration once per source set ("Common", "JVM", …)
      # behind a tab widget, the copies usually differing only in their expect/actual
      # modifier and in the Kotlin version they were introduced in. Keep one copy of
      # each distinct variant and move those differences into a single summary line.
      def collapse_platform_tabs
        all = css('.sourceset-dependent-content[data-togglable]').map { |node| platform(node) }.uniq

        # Reverse document order so nested widgets are collapsed before their ancestors.
        css('.platform-hinted').reverse_each do |node|
          variants = node.element_children.select { |child| sourceset_content?(child) }
          next if variants.empty?

          groups = {}
          variants.each do |variant|
            # Pull the version out first so it is part of neither the key nor the kept copy.
            since = since_nodes(variant)
            source = [platform(variant), since_version(since)]
            since.each(&:remove)

            key = variant_key(variant)
            if (group = groups[key])
              group[:sources] << source
              variant.remove
            else
              groups[key] = { node: variant, sources: [source] }
            end
          end

          groups.each_value do |group|
            label = platform_label(group[:sources], all)
            group[:node].add_previous_sibling(label) if label
            group[:node].replace(group[:node].children)
          end

          node.replace(node.children)
        end
      end

      # Node#matches? re-evaluates the selector against the whole document, which
      # dominates the scrape on the larger package indexes.
      def sourceset_content?(node)
        node['class'].to_s.split.include?('sourceset-dependent-content')
      end

      def platform(node)
        node['data-togglable'].to_s.split('/').last
      end

      MODIFIER = %r{<span class="token keyword">(?:expect|actual)\s*</span>}

      # Two variants are the same declaration when they only differ in their
      # expect/actual modifier; the version has already been removed by the caller.
      def variant_key(variant)
        variant.inner_html.gsub(MODIFIER, '')
      end

      def since_nodes(node)
        node.css('.kdoc-tag, .inline-comment').select { |child| child.content.match?(SINCE) }
      end

      def since_version(since)
        since.first&.content&.split(SINCE)&.last&.squish.presence
      end

      def platform_label(sources, all)
        versions = sources.map(&:last).uniq

        if sources.map(&:first).compact.sort == all.compact.sort && versions.length == 1
          return if versions.first.nil?
          return %(<p class="platform-hint"><b>Since Kotlin:</b> #{versions.first}</p>)
        end

        text = sources.map do |name, version|
          name = PLATFORMS[name] || name || 'Unknown'
          version ? "#{name} (#{version})" : name
        end
        %(<p class="platform-hint"><b>Platform and version requirements:</b> #{text.join(', ')}</p>)
      end
    end
  end
end
