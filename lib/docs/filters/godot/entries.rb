module Docs
  class Godot
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.document h1').content
        name.remove! "\u{00B6}" # Remove the pilcrow
        name
      end

      def get_type
        if slug.start_with?('learning')
          'Learning'
        else
          'API Reference'
        end
      end

      def additional_entries
        return [] unless slug.start_with?('classes')
        class_name = at_css('h1').content
        class_name.remove! "\u{00B6}" # Remove the pilcrow
        entries = []

        # Each page represents a class, and class methods are defined in
        # individual sections.
        css('.simple[id]').each do |node|
          fn_name = node.at_css('strong')
          entries << [class_name + '.' + fn_name + '()', node['id']]
        end

        entries
      end
    end
  end
end
