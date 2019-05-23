module Docs
  class Gnuplot
    PROMOTE = {'Expressions' => nil, 'Linetypes, colors, and styles' => nil, 'Fit' => nil, 'Format' => nil,
               'Plot' => nil, 'Splot' => nil, 'Style' => 'Plot appearance',
               'Set-show' => 'Set / Show', 'Datafile' => nil, 'Key' => 'Legend'}
    NOREPEAT = ['String constants, string variables, and string functions', 'Substitution and Command line macros']

    class EntriesFilter < Docs::EntriesFilter
      def initialize(*)
        super
      end

      def get_name
        return 'Stats' if slug.downcase == 'stats_statistical_summary'
        return css('h1')[0].content.strip
      end

      def get_type
        return (PROMOTE[name] || name) if PROMOTE.include? name

        parent = at_css('.navigation > b:contains("Up:")').next_element.content
        return 'Using Gnuplot' if parent == 'Gnuplot'
        return parent
      end

      def include_default_entry?
        !root_page? and slug.downcase != 'complete_list_terminals' #and !PROMOTE.include? name
      end

      def additional_entries
        return [] if root_page?
        entries = []

        if slug.downcase == 'complete_list_terminals'
          list_stack = [[css('ul.ChildLinks'), '', nil]]
        else
          list_stack = [[css('ul.ChildLinks'), name, nil]]
        end

        while !list_stack.empty?
          list, name_, type_ = list_stack.pop
          list.css('> li').each do |item|

            sublists = item.css('> ul')
            link = item.css('> a, span')

            if link.empty?
              item_name = name_
            else
              item_name = link[0].text.strip
              item_name = "#{name_} #{item_name}".strip unless PROMOTE.include? name_ or NOREPEAT.include? name_
              item_name = item_name.sub /^(\w+) \1/, '\1'
              item_name = 'set style boxplot' if slug.downcase == 'set_show' and item_name == 'Boxplot'

              if PROMOTE.include? name_
                type_ = PROMOTE[name_] || name_
              end

              entries << [item_name, link[0]['href'].split('#')[1], type_]
            end

            list_stack.push([sublists, item_name, type_]) unless sublists.empty?
          end
        end

        return entries
      end

      private

    end
  end
end
