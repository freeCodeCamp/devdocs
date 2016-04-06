module Docs
  class Fortran
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        1 => 'Introduction',
        2 => 'GNU Fortran Command Options',
        3 => 'Runtime Environment Variables',
        4 => 'Fortran 2003 and 2008 Status',
        5 => 'Compiler Characteristics',
        6 => 'Extensions',
        7 => 'Mixed Language Programming',
        8 => 'Coarray Programming',
        9 => 'Intrinsic Procedures',
        10 => 'Intrinsic Modules' }

      def chapter_number
        at_css('h1').content.to_i
      end

      def include_default_entry?
        REPLACE_TYPES[chapter_number] and not at_css('ul.menu')
      end

      def get_name
        at_css('h1').content.split(' ').drop(1).join(' ').split('—').first
      end

      def get_type
        REPLACE_TYPES[chapter_number]
      end

    end
  end
end
