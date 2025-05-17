module Docs
  class Vertx
    class EntriesFilter < Docs::EntriesFilter
      # Determines the default name of the page entry
      def get_name
        node = at_css('h1')
        return nil unless node

        result = node.content.strip
        result = "v5.0.0 - #{result}" if slug.include?('5.0.0')
        result << ' event' if type == 'Events'
        result << '()' if node['class'].to_s.include?('function')
        result
      end

      # Determines the type of the default entry (used for sidebar grouping)
      def get_type
        return nil if root_page?

        node = at_xpath('/html/body/div/div/div[2]/main/div[1]/div[1]')
        node ? node.text.strip : 'Miscellaneous'
      end

      # Returns additional entries from subheadings (usually <h2>)
      def additional_entries
        # return [] if root_page?
        #
        # css('h2').map do |node|
        #   name = node.content.strip
        #   id = node['id']
        #   [name, id, type]
        # end
        []
      end

      # Determines whether to include the default entry for the page
      def include_default_entry?
        !at_css('.obsolete')
      end
    end
  end
end

