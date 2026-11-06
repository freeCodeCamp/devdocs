module Docs
  class Drizzle
    class CleanHtmlFilter < Filter
      LANGUAGES = {
        'bash' => 'bash',
        'js' => 'javascript',
        'json' => 'json',
        'shell' => 'bash',
        'sql' => 'sql',
        'ts' => 'typescript',
        'typescript' => 'typescript',
        'yml' => 'yaml'
      }

      def call
        nav_label = at_css('.nav-items .nav-item--active')&.content&.strip
        @doc = at_css('.documentation-content')

        doc.prepend_child("<h1>#{CGI.escape_html(nav_label)}</h1>") if nav_label && !at_css('h1')

        css('.autolink-header', '.btn-container', '.button-wrap', '.expand-button-wrap',
            '.sub-on-newsletter', '.youtube-cards__wrap', '.flex-container', 'svg', 'rem', 'rem025').remove

        css('h2, h3, h4').each do |node|
          node.remove if ['---', 'Video Showcase', 'What’s next?'].include?(node.content.strip)
        end

        css('h2#sql-template').each do |node|
          node.inner_html = node.inner_html.sub('sql“', '<code>sql``</code>')
        end

        css('a > img[src*="bestofjs"]').each { |node| node.parent.remove }
        css('img[src*="drizzle31kb"]').remove

        # Animated terminal recordings, a few MB each
        css('p > img').each { |node| node.parent.remove } if slug.start_with?('drizzle-kit-')

        css('.npm__wrapper').each do |node|
          figure = node.at_css('.npm__content > figure')
          figure.at_css('pre')['data-language'] = 'shell'
          node.replace(figure)
        end

        css('.codetabs_wrapper').each do |node|
          labels = node.css('> .codetabs_tabs > div')
          blocks = node.at_css('> .codetabs_codeBlock')
          untab(node, labels, blocks.element_children)
        end

        css('.tabs__wrap').each do |node|
          labels = node.css('> .tabs__buttons > div')
          blocks = node.css('> .tabs__content > .tab__content')
          untab(node, labels, blocks)
        end

        css('.header__wrap', '.section__wrap', '.codetab_wrapper', '.tab__content', '.steps', '.custom-table').each do |node|
          node.before(node.children).remove
        end

        css('figure.code-snippet').each do |node|
          if (title = node.at_css('figcaption .title'))
            node.before(pre_heading(title.content))
          end

          pre = node.at_css('pre')
          language = LANGUAGES[pre['data-language']]
          pre.content = pre.content
          pre.attributes.each_key { |name| pre.remove_attribute(name) }
          pre['data-language'] = language if language
          node.replace(pre)
        end

        # Inner callouts first, as some are nested
        css('.callout-wrap').reverse_each do |node|
          label = node.previous_element if node.previous_element&.matches?('.callout-label')
          title = node.at_css('> .callout-content > div > .collapsed-label')
          content = node.at_css('> .callout-content > .content')

          node.children.unlink
          node.add_child(content.children)
          node['class'] = label&.matches?('.error') ? '_note _note-red' : '_note'

          node.prepend_child(strong_paragraph(title.content)) if title && title.content !~ /\A\s*Expand\b/
          node.prepend_child(strong_paragraph(label.content)) if label
          label&.remove
        end

        css('.prerequisites_wrap').each do |node|
          title = node.at_css('.prerequisites_title')
          title.replace(strong_paragraph(title.content))
          node['class'] = '_note'
        end

        css('.tag').each do |node|
          node.replace(strong_paragraph(node.content))
        end

        css('> br').remove

        # Tables open with an empty column the site hides
        css('table').each do |node|
          rows = node.css('tr')
          next unless rows.all? { |row| row.element_children.first&.content&.strip&.empty? }
          rows.each { |row| row.element_children.first.remove }
        end

        css('*').each do |node|
          node.attributes.each_key do |name|
            next if name == 'data-language'
            node.remove_attribute(name) if %w(style tabindex target rel).include?(name) || name.start_with?('data-')
          end
          node.remove_attribute('class') unless node['class'].to_s.start_with?('_')
        end

        doc
      end

      private

      def untab(node, labels, blocks)
        labels.zip(blocks) do |label, block|
          block.before(pre_heading(label.content))
        end

        node.replace(blocks.first.parent.children)
      end

      def pre_heading(label)
        %(<div class="_pre-heading">#{CGI.escape_html(label.strip)}</div>)
      end

      def strong_paragraph(text)
        %(<p><strong>#{CGI.escape_html(text.strip)}</strong></p>)
      end
    end
  end
end
