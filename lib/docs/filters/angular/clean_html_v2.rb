module Docs
  class Angular
    class CleanHtmlV2Filter < Filter
      def call
        container = at_css('article.docs-content')
        badges = css('header.hero .badge, header.hero .hero-subtitle').map do |node|
          node.name = 'span'
          node['class'] = 'status-badge'
          node.to_html
        end.join(' ')
        badges = %(<div class="badges">#{badges}</div>)
        container.child.before(at_css('header.hero h1')).before(badges).before(css('header.hero + .banner, header.hero .breadcrumbs'))
        @doc = container

        title = at_css('h1').content.strip
        if root_page?
          at_css('h1').content = 'Angular 2 Documentation'
        elsif title == 'Index'
          at_css('h1').content = result[:entries].first.name
        elsif title == 'Angular'
          at_css('h1').content = slug.split('/').last.gsub('-', ' ')
        elsif at_css('.breadcrumbs') && title != result[:entries].first.name
          at_css('h1').content = result[:entries].first.name
        end

        css('pre.no-bg-with-indent').each do |node|
          node.content = '  ' + node.content.gsub("\n", "\n  ")
        end

        css('.openParens').each do |node|
          node.parent.name = 'pre'
          node.parent.content = node.parent.css('code, pre').map(&:content).join("\n")
        end

        css('button.verbose', 'button.verbose + .l-verbose-section', 'a[id=top]', 'a[href="#top"]', '.sidebar', 'br').remove

        css('.c10', '.showcase', '.showcase-content', '.l-main-section', 'div.div', 'div[flex]', 'code-tabs', 'md-card', 'md-card-content', 'div:not([class])', 'footer', '.card-row', '.card-row-container', 'figure', 'blockquote', 'exported', 'defined', 'div.ng-scope', '.code-example header', 'section.desc', '.row', '.dart-api-entry-main', '.main-content', 'section.summary', 'span.signature').each do |node|
          node.before(node.children).remove
        end

        css('span.badges').each do |node|
          node.name = 'div'
        end

        css('pre[language]').each do |node|
          node['data-language'] = node['language'].sub(/\Ats/, 'typescript').strip
          node['data-language'] = 'html' if node.content.start_with?('<')
          node.remove_attribute('language')
          node.remove_attribute('format')
        end

        css('pre.prettyprint').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'dart' if node['class'].include?('dart')
          node['data-language'] = 'html' if node.content.start_with?('<')
          node.remove_attribute('class')
        end

        css('.multi-line-signature').each do |node|
          node.name = 'pre'
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

        css('.filetree .children').each do |node|
          node.css('.file').each do |n|
            n.content = "  #{n.content}"
          end
        end

        css('.filetree').each do |node|
          node.content = node.css('.file').map(&:inner_html).join("\n")
          node.name = 'pre'
          node.remove_attribute('class')
        end

        css('.status-badge').each do |node|
          node.name = 'code'
          node.content = node.content.strip
          node.remove_attribute('class')
        end

        css('div.badges').each do |node|
          node.name = 'p'
        end

        css('td h3', '.l-sub-section > h3', '.alert h3', '.row-margin > h3').each do |node|
          node.name = 'h4'
        end

        css('.l-sub-section', '.alert', '.banner').each do |node|
          node.name = 'blockquote'
        end

        css('.code-example > h4').each do |node|
          node['class'] = 'pre-title'
        end

        css('.row-margin', '.ng-cloak').each do |node|
          node.before(node.children).remove
        end

        css('*[layout]').remove_attr('layout')
        css('*[layout-xs]').remove_attr('layout-xs')
        css('*[flex]').remove_attr('flex')
        css('*[flex-xs]').remove_attr('flex-xs')
        css('*[ng-class]').remove_attr('ng-class')
        css('*[align]').remove_attr('align')
        css('h1, h2, h3').remove_attr('class')

        doc
      end
    end
  end
end
