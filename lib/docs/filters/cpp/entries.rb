module Docs
  class Cpp
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_NAMES = {
        'Error directive' => '#error directive',
        'Filename and line information' => '#line directive',
        'Implementation defined behavior control' => '#pragma directive',
        'Replacing text macros' => '#define directive',
        'Source file inclusion' => '#include directive' }

      def get_name
        name = at_css('#firstHeading').content.strip
        name = format_name(name)
        name.split(',').first
      end

      def get_type
        if at_css('#firstHeading').content.include?('C++ keyword')
          'Keywords'
        elsif subpath.start_with?('experimental')
          'Experimental libraries'
        elsif subpath.start_with?('language/')
          'Language'
        elsif subpath.start_with?('freestanding')
          'Utilities'
        elsif type = at_css('.t-navbar > div:nth-child(4) > :first-child').try(:content)
          type.strip!
          type.remove! ' library'
          type.remove! ' utilities'
          type.remove! 'C++ '
          type.capitalize!
          type
        end
      end

      def additional_entries
        return [] if root_page? || self.name.start_with?('operators')
        names = at_css('#firstHeading').content.remove(%r{\(.+?\)}).split(', ')[1..-1]
        names.each(&:strip!).reject! do |name|
          name.size <= 2 || name == '...' || name =~ /\A[<>]/ || name.start_with?('operator')
        end
        names.map { |name| [format_name(name)] }
      end

      def format_name(name)
        name.remove! 'C++ concepts: '
        name.remove! 'C++ keywords: '
        name.remove! 'C++ ' unless name == 'C++ language'
        name.remove! %r{\s\(.+\)}

        name.sub! %r{\AStandard library header <(.+)>\z}, '\1'
        name.sub! %r{(<[^>]+>)}, ''

        if name.include?('operator') && name.include?(',')
          name.sub!(%r{operator.+([\( ])}, 'operators (') || name.sub!(%r{operator.+}, 'operators')
          name.sub! '  ', ' '
          name << ')' unless name.last == ')' || name.exclude?('(')
          name.sub! '()', ''
          name.sub! %r{\(.+\)}, '' if !name.start_with?('operator') && name.length > 50
        end

        REPLACE_NAMES[name] || name
      end
    end
  end
end
