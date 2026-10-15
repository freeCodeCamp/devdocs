module Docs
  class Bootstrap
    class CleanHtmlV6Filter < Filter
      def call

        @doc = at_css('main')
        at_css('.bd-content').prepend_child(at_css('h1').remove)
        @doc = at_css('.bd-content')

        at_css('h1').content = 'Bootstrap' if root_page?

        # Live examples and demo dialogs
        css('.bd-example', 'dialog', 'script', 'button[data-bs-toggle]').remove

        # Interactive playgrounds, swatches and prev/next navigation
        css('.bd-links-nav', '.bd-colors-grid', '.bd-playground', '.bd-scrollspy-debug', 'svg:has(symbol)').remove

        css('.anchor-link', '.bd-details-icon').remove

        css('.bd-code-snippet').each do |node|
          label = node.at_css('.highlight-toolbar .font-monospace')&.content&.strip&.downcase
          tabs = node.css('.code-tab-btn').map { |btn| btn.content.strip }

          html = node.css('pre').each_with_index.map do |pre, i|
            out = Nokogiri::XML::Node.new('pre', doc)
            lang = tabs.empty? ? language(label) : 'shell'
            out['data-language'] = lang if lang
            out.content = pre.content
            tabs[i] ? "<p><strong>#{tabs[i]}</strong></p>#{out.to_html}" : out.to_html
          end.join

          node.replace(html)
        end

        # Remaining live demos (option pickers etc.)
        doc.element_children.each do |node|
          node.remove if node.name == 'div' && node.at_css('button, input, select')
        end

        css('.bd-callout').each do |node|
          node.name = 'blockquote'
        end

        css('table').each do |node|
          node.remove_attribute('class')
        end

        css('td[data-cell]').remove_attr('data-cell')

        doc

      end

      def language(label)
        label = File.extname(label)[1..] if label.include?('.')
        case label
        when 'js', 'javascript' then 'javascript'
        when 'ts', 'typescript' then 'typescript'
        when 'sh', 'bash', 'shell', 'console' then 'shell'
        when 'text', 'plaintext' then nil
        else label
        end
      end
    end
  end
end
