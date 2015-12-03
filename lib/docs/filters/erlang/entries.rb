module Docs
  class Erlang
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').try(:content).try(:strip)
      end

      def get_type
        return nil if 'STDLIB Reference Manual' == name
        name
      end

      def additional_entries
        css('div.REFBODY+p > a').map do |node|

          id = node.attribute('name').value

          # Here, "node" represents an empty <a> tag. It will later be removed
          # by CleanTextFilter.
          # We need to pass its id attribute to another element in order to
          # make the function anchors in the sidebar work properly.
          node.next_sibling['id'] = id
          node.next_sibling['class'] = 'function-name'

          if id == name
            # Module index page
            [name, id, name]
          else
            # Erlang functions are identified
            # by name + arity (no. of parameters).
            # The notation is func_name/arity

            # Replaces the last hyphen with a slash.
            # E.g: to_string-3 becomes to_string/3
            function_name = id.gsub(/\-(?<arity>.*)$/, '/\k<arity>')
            ["#{name}:" + function_name, id, name]
          end
        end
      end
    end
  end
end
