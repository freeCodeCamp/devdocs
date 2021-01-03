module Docs
  class Ocaml
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = context[:html_title].gsub(/\u00A0/, " ")
        title = title.split.join(" ").strip
        title.gsub!(/^Chapter /, "")

        # Move preface at the beginning
        title.gsub!(/^(Contents)/, '00.1 \1')
        title.gsub!(/^(Foreword)/, '00.2 \1')

        # Pad chapter numbers with zeros to sort lexicographically
        title.gsub!(/(^\d[\. ])/, '0\1')
        title.gsub!(/(?<ma>^\d+\.)(?<mb>\d[\. ])/, '\k<ma>0\k<mb>')

        # Add dot between chapter number and title
        title.gsub!(/(^[\d.]+)/, '\1. ')

        title
      end

      def get_type
        if slug.start_with?('libref')
          if slug.start_with?('libref/index_')
            'Indexes'
          else
            'Library reference'
          end
        else
          'Documentation'
        end
      end

      def additional_entries
        entries = []

        module_node = at_css('h1')

        css('pre > span[id]').each do |span|
          if span['id'].start_with?('VAL')
            entry_type = 'Values'
          elsif span['id'].start_with?('MODULE')
            entry_type = 'Modules'
          elsif span['id'].start_with?('EXCEPTION')
            entry_type = 'Exceptions'
          else
            next
          end

          name = span.content
          name += " [#{module_node.content}]" if module_node
          entries << [name, span['id'], entry_type]
        end
        entries
      end
    end
  end
end
