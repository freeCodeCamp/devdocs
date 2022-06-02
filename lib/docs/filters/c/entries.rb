module Docs
  class C
    class EntriesFilter < Docs::EntriesFilter
      ADDITIONAL_NAMES = {
        'Conditional inclusion' => %w(if else elif ifdef ifndef endif).map { |s| "##{s} directive" },
        'Function specifiers' => ['inline specifier', '_Noreturn specifier'] }

      REPLACE_NAMES = {
        'Error directive' => '#error directive',
        'Filename and line information' => '#line directive',
        'Implementation defined behavior control' => '#pragma directive',
        'Replacing text macros' => '#define directive',
        'Source file inclusion' => '#include directive',
        'Warning directive' => '#warning directive' }

      def get_name
        name = at_css('#firstHeading').content.strip
        name.remove! 'C keywords: '
        name.remove! %r{\s\(.+\)}
        name = name.split(',').first
        REPLACE_NAMES[name] || name
      end

      def get_type

        return "C keywords" if slug =~ /keyword/

        type = at_css('.t-navbar > div:nth-child(4) > :first-child').try(:content)
        type.strip!
        type.remove! ' library'
        type.remove! ' utilities'
        type
      end

      def additional_entries
        names = at_css('#firstHeading').content.split(',')[1..-1]
        names.concat ADDITIONAL_NAMES[name] || []
        names.map { |name| [name] }
      end
    end
  end
end
