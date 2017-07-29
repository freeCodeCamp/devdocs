module Docs
  class Vulkan
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
        # As only documentation is single-paged, hardcode type
        initial_page? ? 'Vulkan' : 'Specifications'
      end

      def include_default_entry?
        # additional_entries is responsible to extract relevant entries
        false
      end

      def additional_entries
        if initial_page?
          # We pack each subsections into their corresponding category for apispec.html
          subsections = css('.sect2').map do |node|
            # Parse '.sect1' parent, to know what is the entry's type
            parent_node = node.parent.parent
            # Type is the parent's h2 header
            type = parent_node.at_css('h2').content.strip
            # Entry node is the one under h3
            header_node = node.at_css('h3')
            [header_node.content, header_node['id'], type]
          end
        else
          # We create a new category for vkspec.html page
          main_sections = css('.sect1').map do |node|
            # Entry node is the one under h2
            header_node = node.at_css('h2')
            [header_node.content, header_node['id'], 'Specifications']
          end
        end
      end
    end
  end
end
