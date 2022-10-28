module Docs
  class Godot
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! "\u{00B6}" # Remove the pilcrow
        name
      end

      TYPE_BY_LEARNING_PATH = {
        'step_by_step' => 'Guides: Step by step',
        'editor' => 'Guides: Editor',
        'features' => 'Guides: Engine features',
        'scripting' => 'Guides: Scripting',
        'workflow' => 'Guides: Project workflow'
      }

      def get_type
        if slug.start_with?('learning')
          TYPE_BY_LEARNING_PATH[slug.split('/')[1]]
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
        return false if subpath.start_with?('learning') && subpath.end_with?('index.html')
        return false if subpath == 'classes/index.html'
        true
      end
    end
  end
end
