module Docs
  class Codeception
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = (at_css('.js-algolia__initial-content h1') || at_css('.js-algolia__initial-content h2')).content

        if number = subpath[/\A\d+/]
          name.prepend "#{number.to_i}. "
        end

        name
      end

      def get_type
        if subpath =~ /\d\d/
          'Guides'
        elsif subpath.start_with?('modules')
          "Module: #{name}"
        elsif name.include?('Util')
          "Util Class: #{name.split('\\').last}"
        else
          "Reference: #{name}"
        end
      end

      def additional_entries
        if type =~ /Module/
          prefix = "#{name}::"
          pattern = at_css('#actions') ? '#actions ~ h4' : '#page h4'
        elsif type =~ /Functions/
          prefix = ''
          pattern = '#page h4'
        elsif name =~ /Util/
          prefix = "#{name.remove('Codeception\\Util\\')}::"
          pattern = '#page h4'
        elsif type =~ /(Commands)|(Configuration)/
          prefix = ''
          pattern = 'h2'
        end

        return [] unless pattern

        css(pattern).map do |node|
          [prefix + node.content, node['id']]
        end.compact
      end
    end
  end
end
