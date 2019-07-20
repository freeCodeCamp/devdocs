module Docs
  class Handlebars
    class CleanHtmlFilter < Filter
      def call
        # Remove the t-shirt shop advertisement
        css('#callout').remove

        # The title filter is used to add titles to pages without one, remove original headers
        css('h1').remove

        # Remove the link to the issue tracker
        css('.issue-tracker').remove

        css('pre').each do |node|
          # Remove nested nodes inside pre tags
          node.content = node.content

          # Add syntax highlighting
          node['data-language'] = 'html'
        end

        # Transform 'Learn More' links to headers in the "Getting Started" part of the homepage
        # If this step is skipped, that section looks cluttered with 4 sub-sections without any dividers
        css('#getting-started + .contents a.more-info').each do |node|
          clone = node.clone

          # Move it to the top of the sub-section
          node.parent.prepend_child(clone)

          # Turn it into a header
          clone.name = 'h3'

          # Remove the "Learn More: " part
          clone.content = clone.content[12..-1]
        end

        # Remove class attributes from div elements to reduce file size
        css('div').remove_attr('class')

        doc
      end
    end
  end
end
