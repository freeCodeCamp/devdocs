module Docs
  class Tanstack
    class CleanHtmlFilter < Filter
      LANGUAGES = {
        'tsx' => 'jsx',
        'ts' => 'typescript',
        'js' => 'javascript',
        'shell' => 'bash',
        'sh' => 'bash',
        'zsh' => 'bash'
      }

      def call
        title = at_css('h1')
        @doc = at_css('.prose')
        doc.prepend_child(title)

        css('.anchor-heading-link', 'button').remove

        css('.codeblock').each do |node|
          pre = node.at_css('pre')
          label = node.at_css('> div:first-child > div').try(:content).try(:strip)
          if label.present? && label != pre['data-language']
            node.before(%(<div class="_pre-heading">#{CGI.escapeHTML(label)}</div>))
          end
          node.replace(pre)
        end

        css('pre').each do |node|
          node.content = node.content
          node.remove_attribute('class')
          node['data-language'] = LANGUAGES[node['data-language']] if LANGUAGES.key?(node['data-language'])
        end

        css('span.border.rounded[class~="bg-gray-500/10"]').each do |node|
          node.name = 'code'
          node.remove_attribute('class')
        end

        css('.markdown-alert').each do |node|
          node['class'] = '_note'
          node.at_css('.markdown-alert-title').try(:name=, 'strong')
        end

        css('input[type="checkbox"]').each do |node|
          node.replace(node['checked'] ? '☑' : '☐')
        end

        # Strip Tailwind classes and tab widget attributes, then unwrap the bare layout divs
        css('*').each do |node|
          node.remove_attribute('class') unless node['class'].try(:start_with?, '_')
          node.remove_attribute('id') if node['id'].try(:start_with?, ':')
          node.attributes.each_key { |name| node.remove_attribute(name) if name.start_with?('aria-', 'data-tab', 'data-content') || name == 'role' }
        end

        css('div:not([class])').each do |node|
          node.replace(node.children)
        end

        doc
      end
    end
  end
end
