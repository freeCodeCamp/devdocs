module Docs
  class Elixir
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.gsub('behaviour', ' ').strip
      end

      def get_type
        return nil if (slug.split("#")[1] == "functions")
        slug.split("#")[1]
      end

      def additional_entries
        return [] if root_page?
       
        entries = [] 

        # Add itself (moduledoc) to entries
        klass = at_css('h1').content.strip.split(" ")[0]
        entries << [klass, klass, name]

        # Add functions
        css('.summary-functions .summary-signature a').each do |node|
          entries << [(name + node['href']), node['href'][1..-1], name]
        end

        return entries
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
