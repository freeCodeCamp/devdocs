module Docs
  class Graphite
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children[0].to_s
      end

      def get_type
        get_name
      end

      def additional_entries
        entries = []

        # Sections
        css('.section > .section').each do |node|
          title = node.at_css('h2, h3')

          next if title.nil?

          # Move the id attribute to the title
          # If this is excluded, the complete section will be highlighted in yellow when someone navigates to it
          title['id'] = node['id']
          node.remove_attribute('id')

          parent_title_selector = "parent::div[@class='section']/preceding::#{title.name == 'h2' ? 'h1' : 'h2'}"

          entries << [
            title.children[0].to_s,
            title['id'],
            title.xpath(parent_title_selector).last.children[0].to_s
          ]
        end

        # Functions
        css('dl.function > dt').each do |node|
          name = node.at_css('.descname').content
          name << '()'
          entries << [name, node['id'], 'Functions']
        end

        entries
      end
    end
  end
end
