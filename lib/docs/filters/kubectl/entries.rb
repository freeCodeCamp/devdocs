module Docs
  class Kubectl
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name
      end

      def get_type
        name
      end

      def additional_entries
        entries = []
        group = 'kubectl'
        commands = css('h1').to_a()
        commands.map do |node|
          # handle titles differnetly by converting them into sidebar groups (types)
          new_group = at_css("##{node['id']} > strong")
          if new_group
            group = new_group.content.titleize
          else
            # prepend kubectl before every command
            command_name = 'kubectl ' + node.content
            entries << [command_name, node['id'], group]
          end
        
        end

        entries
      end

      def include_default_entry?
        false
      end
    end
  end
end
