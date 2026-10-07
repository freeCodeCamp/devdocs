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

        doc
      end
    end
  end
end
