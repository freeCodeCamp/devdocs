module Docs
  class Angular
    class CleanHtmlFilter < Filter
      def call
        container = at_css('article.docs-content')
        badges = css('header.hero .badge, header.hero .hero-subtitle').map do |node|
          node.name = 'span'
          node['class'] = 'status-badge'
          node.to_html
        end.join(' ')
        badges = %(<div class="badges">#{badges}</div>)
        container.child.before(at_css('header.hero h1')).before(badges).before(css('header.hero + .banner'))
        @doc = container

        title = at_css('h1').content.strip
        if title == 'Index'
          at_css('h1').content = result[:entries].first.name
        elsif title == 'Angular'
          at_css('h1').content = slug.split('/').last.gsub('-', ' ')
        end

        css('pre.no-bg-with-indent').each do |node|
          node.content = '  ' + node.content.gsub("\n", "\n  ")
        end

        css('.openParens').each do |node|
          node.parent.name = 'pre'
          node.parent.content = node.parent.css('code, pre').map(&:content).join("\n")
        end

        css('button.verbose', 'button.verbose + .l-verbose-section', 'a[id=top]', 'a[href="#top"]').remove

        css('.c10', '.showcase', '.showcase-content', '.l-main-section', 'div.div', 'div[flex]', 'code-tabs', 'md-card', 'md-card-content', 'div:not([class])', 'footer', '.card-row', '.card-row-container', 'figure', 'blockquote', 'exported', 'defined', 'div.ng-scope', '.code-example header').each do |node|
          node.before(node.children).remove
        end

        css('span.badges').each do |node|
          node.name = 'div'
        end

        css('pre[language]').each do |node|
          node['data-language'] = node['language'].sub(/\Ats/, 'typescript').strip
        end

        css('pre.prettyprint').each do |node|
          node.content = node.content.strip
        end

        css('a[id]:empty').each do |node|
          node.next_element['id'] = node['id'] if node.next_element
        end

        css('a[name]:empty').each do |node|
          node.next_element['id'] = node['name'] if node.next_element
        end

        css('tr[style]').each do |node|
          node.remove_attribute 'style'
        end

        css('h1:not(:first-child)').each do |node|
          node.name = 'h2'
        end unless at_css('h2')

        css('img[style]').each do |node|
          node['align'] ||= node['style'][/float:\s*(left|right)/, 1]
          node['style'] = node['style'].split(';').map(&:strip).select { |s| s =~ /\Awidth|height/ }.join(';')
        end

        css('.example-title + pre').each do |node|
          node['name'] = node.previous_element.content.strip
          node.previous_element.remove
        end

        css('pre[name]').each do |node|
          node.before(%(<div class="pre-title">#{node['name']}</div>))
        end

        css('a.is-button > h3').each do |node|
          node.parent.content = node.content
        end

        css('#angular-2-glossary ~ .l-sub-section').each do |node|
          node.before(node.children).remove
        end

        location_badge = at_css('.location-badge')
        if location_badge && doc.last_element_child != location_badge
          doc.last_element_child.after(location_badge)
        end

        doc
      end
    end
  end
end
