module Docs
  class GnuFortran
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_CHAPTER = { }

      def initialize(*)
        super
        detect_chapters if root_page?
      end

      def get_name
        at_css('h1').content.split(' ').drop(1).join(' ').split('—').first
      end

      def get_type
        "#{chapter_number}. #{TYPE_BY_CHAPTER[chapter_number]}"
      end

      def include_default_entry?
        !at_css('ul.menu')
      end

      private

      def detect_chapters
        css('.contents > ul > li > a').each do |node|
          index = node.content.strip.to_i
          next unless index > 0
          name = node.content.split(' ').drop(1).join(' ')
          name.remove! 'GNU Fortran '
          name.remove! %r{:.*}
          TYPE_BY_CHAPTER[index] = name # YOLO
        end
      end

      def chapter_number
        at_css('h1').content.to_i
      end
    end
  end
end
