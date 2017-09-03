module Docs
  class Gnu
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_CHAPTER = { }

      def initialize(*)
        super
        detect_chapters if root_page?
      end

      def get_name
        name = at_css('h1').content
        name.sub! %r{\A([\d\.]*\d)}, '\1.'
        name.split('—').first.strip
      end

      def get_type
        "#{chapter_number}. #{TYPE_BY_CHAPTER[chapter_number]}"
      end

      private

      def detect_chapters
        TYPE_BY_CHAPTER.clear # YOLO
        css('.contents > ul > li > a').each do |node|
          index = node.content.strip.to_i
          next unless index > 0
          name = node.content.split(' ').drop(1).join(' ')
          name.remove! 'GNU Fortran '
          name.remove! 'with GCC'
          name.remove! %r{[\:\u{2013}\u{2014}].*}
          TYPE_BY_CHAPTER[index] = name
        end
      end

      def chapter_number
        [at_css('h1').content.to_i, 1].max
      end
    end
  end
end
