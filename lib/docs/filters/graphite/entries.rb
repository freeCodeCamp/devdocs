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
        css('.section').each do |node|
          title = node.at_css('h2, h3')

          next if title.nil?

          # Move the id attribute to the title
          # If this is excluded, the complete section will be highlighted in yellow when someone navigates to it
          title['id'] = node['id']
          node.remove_attribute('id')

          entry = [title.children[0].to_s, title['id']]

          # Separate sub-sections in additional types
          if title.name == 'h3'
            entry.push title.xpath('parent::div[@class="section"]/preceding::h2').last.children[0].to_s
          end

          entries << entry
        end

        # Functions
        css('dl.function > dt').each do |node|
          entries << [node['data-name'], node['id'], 'List of functions']
        end

        entries
      end
    end
  end
end
