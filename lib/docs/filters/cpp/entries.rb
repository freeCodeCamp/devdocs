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
        name.sub! 'C++ concepts: ', ''
        name.sub! 'C++ keywords: ', ''
        name.sub! 'C++ ', ''
        name.sub! %r{\s\(.+\)}, ''
        name.sub! %r{\AStandard library header <(.+)>\z}, '\1'
        name = name.split(',').first
        REPLACE_NAMES[name] || name
      end

      def get_type
        if at_css('#firstHeading').content.include?('C++ keyword')
          'Keywords'
        elsif type = at_css('.t-navbar > div:nth-child(4) > :first-child').try(:content)
          type.strip!
          type.sub! ' library', ''
          type.sub! ' utilities', ''
          type.sub! 'C++ ', ''
          type.capitalize!
          type
        end
      end

      def additional_entries
        return [] unless include_default_entry?
        names = at_css('#firstHeading').content.gsub(%r{\(.+?\)}, '').split(',')[1..-1]
        names.each(&:strip!).reject! do |name|
          name.size <= 2 || name == '...' || name =~ /\A[<>]/ || name.start_with?('operator')
        end
        names.map { |name| [name] }
      end

      def include_default_entry?
        return @include_default_entry if defined? @include_default_entry
        @include_default_entry = at_css('.t-navbar > div:nth-child(4) > a') && at_css('#firstHeading').content !~ /\A\s*operator./
      end
    end
  end
end
