module Docs
  class Css
    class EntriesFilter < Docs::EntriesFilter
      # What the specifications call themselves and what the documentation
      # files them under.
      TYPE_BY_SPEC = {
        'Compositing' => 'Compositing & Blending',
        'Custom Properties for Cascading Variables' => 'Variables',
        'Grid Layout' => 'Grid Layout',
        'Image Values & Replaced Content' => 'Image Values',
        'Scroll Snap' => 'Scroll Snap'
      }

      # The kind of page to fall back on when no specification names it.
      TYPE_BY_PAGE_TYPE = {
        'css-at-rule' => 'At-rules',
        'css-at-rule-descriptor' => 'At-rules',
        'css-combinator' => 'Selectors',
        'css-function' => 'Functions',
        'css-keyword' => 'Keywords',
        'css-media-feature' => 'Media Queries',
        'css-property' => 'Properties',
        'css-pseudo-class' => 'Selectors',
        'css-pseudo-element' => 'Pseudo-Elements',
        'css-selector' => 'Selectors',
        'css-shorthand-property' => 'Properties',
        'css-type' => 'Data Types'
      }

      VENDOR_PREFIXES = %w(-webkit- -moz- -ms- -o-)

      # The descriptors and the media features of an at-rule go by their own
      # name in the content repository; the reference lists them under the
      # at-rule they belong to.
      NESTED = %w(css-at-rule-descriptor css-media-feature)

      def get_name
        name = page.front_matter['short-title'] || default_name
        at_rule ? "#{at_rule}.#{name}" : name
      end

      def default_name
        page.page_type.to_s.start_with?('css-') ? slug.split('/').last : page.title
      end

      def at_rule
        return unless NESTED.include?(page.page_type)
        context[:pages][slug.split('/')[0..-2].join('/')]&.short_title
      end

      def get_type
        return 'Extensions' if VENDOR_PREFIXES.any? { |prefix| name.include?(prefix) }
        specification || TYPE_BY_PAGE_TYPE[page.page_type] || 'Miscellaneous'
      end

      # The specification a page documents, cut down to the part of CSS it
      # covers: "CSS Grid Layout Module Level 2" is the Grid Layout pages.
      def specification
        title = context[:generator].specification_titles(page.browser_compat, page.spec_urls).first
        return if title.blank?

        title = title.dup
        title.remove! 'CSS '
        title.remove! ' Module'
        title.remove! %r{ Level \d+\z}
        title.remove! %r{\(.*\)}
        title.sub! ' and ', ' & '
        title.squish!

        _, type = TYPE_BY_SPEC.find { |spec, _| title.include?(spec) }
        type || (title.match?(/\ALevel \d+\z/) ? nil : title.presence)
      end

      def page
        context[:page]
      end
    end
  end
end
