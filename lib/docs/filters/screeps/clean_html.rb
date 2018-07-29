module Docs
  class Screeps
    class CleanHtmlFilter < Filter
      def call
        # The root page isn't useful
        if subpath == 'index.html'
          doc.inner_html = '<h1>Screeps</h1>'
          return doc
        end

        # The API Reference and the manual pages are completely different themes
        subpath == 'api/' ? clean_api : clean_manual
      end

      def clean_api
        # Extract content
        doc = at_css('.content.api-content')

        # Add proper title
        doc.prepend_child('<h1 class="title">API Reference</h1>')

        # Remove all dividers (they do not appear in the original documentation neither)
        css('h1.divider').remove

        # Fix id's (the original reference does this with JS, which doesn't run when it's being scraped)
        headers = css('h1[id], h2[id]')
        last_class = ''
        headers.each do |node|
          if node['id'].include?('-')
            node['id'] = node['id'].split('-').join('.')
            node['id'] = node['id'][10..-1] if node['id'].start_with?('Structure.')
          end

          if node.name == 'h1'
            last_class = node.content
          else
            unless node['id'].start_with?(last_class)
              node['id'] = "#{last_class}.#{node['id']}"
            end
          end
        end

        # Replace certain headers with smaller variants
        css('h2.api-property').each {|node| node.name = 'h3'}
        css('h1[id]').each {|node| node.name = 'h2'}
        css('h3[id^="Return-value"]').each {|node| node.name = 'h4'}

        # Make sure these nodes have content so they are not removed by the CleanText filter
        css('.api-property__cpu').each {|node| node.inner_html = '<img src="https://docs.screeps.com/api/img/cpu.png">'}

        doc
      end

      def clean_manual
        # Extract content
        doc = at_css('.article > .inner')

        # Move title node up one level
        header = at_css('.article-header')
        header.replace(header.at_css('.article-title'))

        # Remove navigation footer
        css('.article-footer').remove

        doc
      end
    end
  end
end
