module Docs
  class Firebase
    class CleanHtmlFilter < Filter
      # The language of the code in each tab of a code sample.
      TAB_LANGUAGES = {
        'web' => 'javascript', 'web-namespaced-api' => 'javascript', 'node.js' => 'javascript',
        'nodejs' => 'javascript', 'node' => 'javascript', 'typescript' => 'typescript',
        'swift' => 'swift', 'objective-c' => 'objectivec', 'kotlin' => 'kotlin', 'kotlin+ktx' => 'kotlin',
        'java' => 'java', 'android' => 'java', 'dart' => 'dart', 'flutter' => 'dart', 'python' => 'python',
        'go' => 'go', 'c++' => 'cpp', 'unity' => 'csharp', 'c#' => 'csharp', 'php' => 'php', 'ruby' => 'ruby'
      }

      # Google's page furniture: ratings, feedback, bookmarks, AI tools, tables of contents.
      FURNITURE = %w(
        devsite-thumb-rating devsite-feedback devsite-recommendations devsite-toc devsite-actions
        devsite-bookmark devsite-llm-tools devsite-feature-tooltip devsite-view-release-notes
        devsite-hats-survey devsite-video devsite-iframe
        .nocontent .devsite-github-link .devsite-article-meta .devsite-page-title-meta
        .devsite-floating-action-buttons .devsite-breadcrumb-list .video-wrapper .firebase-ai-prompt-cards
        button script style iframe noscript
      )

      def call
        title = at_css('h1.devsite-page-title')
        body = at_css('.devsite-article-body') || doc
        css(*FURNITURE).remove

        tabs_to_labels(body)
        code_blocks(body)
        # Unknown <devsite-*> wrappers (expandable sections and the like) keep their content.
        body.css('*').each { |node| node.replace(node.children) if node.name.start_with?('devsite-') }
        body.css('[data-text], [tabindex]').each do |node|
          node.remove_attribute('data-text')
          node.remove_attribute('tabindex')
        end
        body.css('.notranslate, .two-line-tab').each { |node| node.replace(node.children) }

        heading = doc.document.create_element('h1')
        # Landing pages (the docs' home, each product's) have no title of their own.
        heading.content = title&.content&.squish.presence || (root_page? ? 'Firebase' : subpath.split('/').first.to_s.tr('-', ' ').capitalize)
        doc.children = heading.to_html + body.inner_html
        doc
      end

      private

      # A code sample's tabs ("Web", "Swift", "Kotlin") become a label above each tab's code.
      def tabs_to_labels(body)
        # Two forms: <devsite-selector> with <h3> labels, and .ds-selector-tabs with <h5> ones.
        body.css('devsite-selector > section, .ds-selector-tabs > section').each do |section|
          tab = section.element_children.first
          next unless tab && tab.name =~ /\Ah[2-6]\z/
          label = tab.content.squish
          section['data-language'] = TAB_LANGUAGES[tab['id'].to_s.downcase] || TAB_LANGUAGES[label.downcase]
          # "Web" comes twice, told apart by a smaller "modular API" / "namespaced API".
          variant = tab.at_css('[tab-label]')&.[]('tab-label').to_s.squish
          label = "#{label} (#{variant})" unless variant.empty?
          tab.replace("<p class=\"_firebase-tab\"><strong>#{CGI.escapeHTML(label)}</strong></p>")
        end
      end

      # The site colours code with <span>s and guesses its language, often wrongly.
      def code_blocks(body)
        body.css('pre').each do |pre|
          language = pre['class'].to_s[/\blang-(\w+)/, 1] ||
                     pre.ancestors('[data-language]').first&.[]('data-language')
          pre.content = pre.content
          pre.attributes.each_key { |name| pre.remove_attribute(name) }
          pre['data-language'] = language if language
        end
        body.css('section[data-language]').each { |section| section.remove_attribute('data-language') }
      end
    end
  end
end
