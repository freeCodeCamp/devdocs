module Docs
  class Angular
    class CleanHtmlFilter < Filter
      def call
        # Fix internal links (remove colons)
        css('a[href]').each do |node|
          node['href'] = node['href'].gsub %r{(directive|filter):}, '\1-'
        end

        root_page? ? root : other
        doc
      end

      def root
        css('.pull-right', '.ng-hide').remove

        # Turn "module [...]" <li> into <h2>
        css('.nav-header.module').each do |node|
          node.name = 'h2'
          node.parent.before(node)
        end

        # Remove links to "Directive", "Filter", etc.
        css('a.guide').each do |node|
          node.replace(node.content)
        end
      end

      def other
        css('#example', '.example', '#description_source', '#description_demo', '[id$="example"]').remove

        if at_css('h1').content.strip.empty?
          # Ensure proper <h1> (e.g. ngResource, AUTO, etc.)
          at_css('h2').tap do |node|
            at_css('h1').content = node.try(:content) || slug
            node.try(:remove)
          end
        else
          # Clean up .hint in <h1>
          css('h1 > div > .hint').each do |node|
            node.parent.before("<small>(#{node.content.strip})</small>").remove
          end
        end

        at_css('h1').add_child(css('.view-source', '.improve-docs'))

        # Remove root-level <div>
        while div = at_css('h1 + div')
          div.before(div.children)
          div.remove
        end

        # Remove dead links (e.g. ngRepeat)
        css('a.type-hint').each do |node|
          node.name = 'code'
          node.remove_attribute 'href'
        end

        # Remove some <code> elements
        css('h1 > code', 'pre > code', 'h6 > code').each do |node|
          node.before(node.content).remove
        end

        # Fix code indentation
        css('code', 'pre').each do |node|
          node.inner_html = node.inner_html.strip_heredoc.strip
        end

        # Make <pre> elements
        css('.in-javascript', '.in-html-template-binding').each do |node|
          node.name = 'pre'
          node.content = node.content
        end

        css('ul.methods', 'ul.properties', 'ul.events').add_class('defs')

        # Remove ng-* attributes
        css('*').each do |node|
          node.attributes.each_key do |attribute|
            node.remove_attribute(attribute) if attribute.start_with? 'ng-'
          end
        end
      end
    end
  end
end
