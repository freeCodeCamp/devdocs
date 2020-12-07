module Docs
  class Nim
    class EntriesFilter < Docs::EntriesFilter

      REFERENCE = [
        'API naming design', 'Internals of the Nim Compiler', 'Nim Backend Integration',
        'Nim Compiler', 'Nim Destructors and Move Semantics', 'Nim Enhancement Proposal #1',
        'Nim Experimental Features', 'Nim IDE Integration Guide',
        'Nim maintenance script', 'Nim Standard Library', "Nim's Memory Management",
        'NimScript', 'Packaging Nim', 'segfaults', 'Source Code Filters'
      ]

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
        if slug == 'manual'
          'Manual'
        elsif REFERENCE.include?(name)
          'Reference'
        else
          name
        end
      end

      def additional_entries
        entries = []

        if slug == 'manual'

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

        else

          css('.simple-toc-section a').each do |node|
            entry_name = node.content
            entry_name.gsub!(/,.*/, '')
            entry_id = slug + node['href']
            entries << [entry_name, entry_id, name]
          end

        end

        entries
      end

    end
  end
end
