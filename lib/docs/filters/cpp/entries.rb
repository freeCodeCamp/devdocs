module Docs
  class Cpp
    class EntriesFilter < Docs::EntriesFilter
      @@canonical_pages = []

      REPLACE_NAMES = {
        'Error directive' => '#error directive',
        'Filename and line information' => '#line directive',
        'Implementation defined behavior control' => '#pragma directive',
        'Replacing text macros' => '#define directive',
        'Source file inclusion' => '#include directive' }

      def get_name
        name = at_css('#firstHeading').content.strip
        name = format_name(name)
        name = name.split(',').first
        name
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
        name.sub! %r{(<[^>]+>::)}, '::'

        if name.include?('operator') && name.include?(',')
          name.sub!(%r{operator.+([\( ])}, 'operators (') || name.sub!(%r{operator.+}, 'operators')
          name.sub! '  ', ' '
          name << ')' unless name.last == ')' || name.exclude?('(')
          name.sub! '()', ''
          name.sub! %r{\(.+\)}, '' if !name.start_with?('operator') && name.length > 50
        end

        REPLACE_NAMES[name] || name
      end

      # Avoid duplicate pages: cppreference serves the same wiki page under
      # several URLs (redirects), and since the scraper stores pages under the
      # requested URL rather than the effective one, each alias would be stored
      # as a separate copy of the same document.
      #
      # Deduplicate on the canonical wiki page name taken from the "Retrieved
      # from" footer, not on the entry name -- unrelated pages legitimately
      # share a name (e.g. std::erase_if for every container, std::move in both
      # <algorithm> and <utility>) and keying on the name silently dropped them.
      def entries
        return [] if duplicate_page?
        super
      end

      def duplicate_page?
        page = canonical_page
        return false if page.nil?
        return true if @@canonical_pages.include?(page)

        @@canonical_pages.push(page)
        false
      end

      # e.g. "cpp/container/unordered_map/erase_if", from the printfooter link
      # to /mwiki/index.php?title=<page>&oldid=<revision>
      def canonical_page
        href = at_css('.printfooter a').try(:[], 'href')
        href && href[/[?&]title=([^&]+)/, 1]
      end

    end
  end
end
