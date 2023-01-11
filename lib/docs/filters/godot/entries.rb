module Docs
  class Godot
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! "\u{00B6}" # Remove the pilcrow
        name
      end

      def get_type
        if slug.start_with?('getting_started')
          # Getting started sections are different even between different minor
          # versions from v3 so we're programmatically generating them instead.
          "Getting started: " + slug.split('/')[1].tr_s('_', ' ').capitalize
        else
          name
        end
      end

      def additional_entries
        return [] unless slug.start_with?('classes')

        css('.simple[id]').each_with_object [] do |node, entries|
          name = node.at_css('strong').content
          next if name == self.name
          name.prepend "#{self.name}."
          name << '()'
          entries << [name, node['id']] unless entries.any? { |entry| entry[0] == name }
        end
      end

      def include_default_entry?
        return false if subpath.start_with?('getting_started') && subpath.end_with?('index.html')
        return false if subpath == 'classes/index.html'
        true
      end
    end
  end
end
