module Docs
  class Codeception
    class EntriesFilter < Docs::EntriesFilter
      def get_name
          (subpath.scan(/\d\d/).first || '') + ' ' + (at_css('h1') || at_css('h2')).content
      end

      def get_type
          return 'Module::' +  (at_css('h1') || at_css('h2')).content if subpath.start_with?('modules')
          return 'Guides' if subpath =~ /\d\d/
          (at_css('h1') || at_css('h2')).content
      end

      def include_default_entry?
        return true if %w(Guides).include? type
        return true if type =~ /(Module)|(Util)/
        false
      end

      def additional_entries

        if type =~ /Module/
          prefix = type.sub(/Module::/, '')+ '::'
          pattern = '#actions ~ h4'
        elsif type =~ /Functions/
          prefix = ''
          pattern = 'h4'
        elsif type =~ /Util/
          prefix = type.sub(/Codeception\/Util/, '')+ '::'
          pattern = 'h3'
        elsif type =~ /(Commands)|(Configuration)/
         prefix = ''
         pattern = 'h2'
        else
          prefix = ''
          pattern = 'none'
        end

        css(pattern).map do |node|
          [prefix + node.content, node['id']]
        end.compact

      end

    end
  end
end
