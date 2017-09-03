module Docs
  class Nim
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! 'Module '
        name.remove! ' User Guide'
        name.remove! ' User\'s manual'
        name.remove! %r{ \-.*}
        name.strip!
        name
      end

      def get_type
        if name.include?('Tutorial')
          'Tutorial'
        elsif slug == 'manual'
          'Manual'
        elsif at_css('h1').content.include?('Module ')
          name
        else
          'Reference'
        end
      end

      def additional_entries
        entries = []

        if at_css('h1').content.include?('Module ')
          css('#toc-list > li > .simple-toc-section').each do |node|
            type = node.previous_element.content.strip

            node.css('a.reference:not(.reference-toplevel)').each do |n|
              n.css('span').remove
              name = n.content.strip
              name << '()' if (type == 'Procs' || type == 'Templates') && !name.include?('`')
              name.remove! '`'
              name.prepend "#{self.name}."
              id = n['href'].remove('#')
              entries << [name, id] unless entries.any? { |e| e[0] == name }
            end
          end
        elsif slug == 'manual'
          css('#toc-list > li > a').each do |node|
            name = node.content.strip
            next if name.start_with?('About')
            id = node['href'].remove('#')
            entries << [name, id]
          end

          css('#toc-list > ul').each do |node|
            type = node.previous_element.content.strip

            node.css('> li > a').each do |n|
              entries << [n.content.strip, n['href'].remove('#'), "Manual: #{type}"]
            end
          end
        end

        entries
      end
    end
  end
end
