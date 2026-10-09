module Docs
  class Erlang
    class CleanHtmlExDocFilter < Filter
      LANGUAGES = { 'erl' => 'erlang', 'sh' => 'bash', 'shell' => 'bash' }

      def call
        css('.top-search', '.footer', '.bottom-actions', '.copy-markdown', '.detail-link', '.hover-link').remove

        css('.top-heading h1 small.app-vsn').remove

        css('.top-heading a.icon-action[aria-label="View Source"]', '.top-heading a.icon-action[title="View Source"]').each do |node|
          node['class'] = 'source'
          node.content = 'Source'
        end

        css('.section-heading').each do |node|
          node.name = 'h2' if node.name == 'h1' # OTP 27
          node.content = node.content.strip
          node.remove_attribute('class')
        end

        css('.summary').each do |node|
          node.name = 'dl'
        end

        css('.summary h2', '.summary h3').each do |node|
          node.name = 'h3'
          node.content = node.content.strip
          node.parent.before(node)
        end

        css('.summary-row').each do |node|
          node.before(node.children).remove
        end

        css('.summary-signature').each do |node|
          node.name = 'dt'
          node.remove_attribute('class')
        end

        css('.summary-synopsis').each do |node|
          node.name = 'dd'
          node.remove_attribute('class')
        end

        css('section.detail').each do |detail|
          id = detail['id']
          detail.remove_attribute('id')

          detail.css('.detail-header').each do |node|
            source = node.at_css('a.icon-action[aria-label="View Source"]', 'a.icon-action[title="View Source"]')
            since = node.at_css('.note')

            node.name = 'h3'
            node['id'] = id
            node.content = node.at_css('.signature').content.strip
            node << %( <span class="since">#{since.content.strip}</span>) if since
            node << %(<a href="#{source['href']}" class="source">Source</a>) if source
          end

          detail.css('.docstring h2', '.docstring h3').each do |node|
            node.name = node.name.sub(/\d/) { |i| i.to_i + 2 }
          end
        end

        css('#top-content', '#moduledoc', '.heading-with-actions').each do |node|
          node.before(node.children).remove
        end

        css('section.admonition').each do |node|
          node.name = 'div'
          node['class'] = node['class'].include?('warning') || node['class'].include?('error') ? 'warning' : 'note'
          node.remove_attribute('role')
          node.css('.admonition-title').each do |title|
            title.name = 'p'
            title['class'] = 'label'
          end
        end

        css('.specs pre').each do |node|
          node['data-language'] = 'erlang'
        end

        css('.specs').each do |node|
          node.before(node.children).remove
        end

        css('pre:not([data-language])').each do |node|
          lang = node.at_css('code')&.[]('class').to_s.remove('makeup').strip
          lang = LANGUAGES.fetch(lang, lang)
          node['data-language'] = lang if lang.present? && !%w(text txt mermaid).include?(lang)
          node.content = node.content
        end

        css('code.inline').each do |node|
          node.remove_attribute('class')
        end

        css('.icon-action', '.sr-only').remove

        css('[translate]').remove_attribute('translate')
        css('[data-no-tooltip]').remove_attribute('data-no-tooltip')

        doc
      end
    end
  end
end
