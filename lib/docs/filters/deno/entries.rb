module Docs
  class Deno
    class EntriesFilter < Docs::EntriesFilter
      TYPES_BY_PATH = {
        'api'     => 'API',
        'runtime' => 'Runtime',
      }

      def get_name
        name = at_css('h1')
        name ? name.content.strip : slug.split('/').last
      end

      def get_type
        TYPES_BY_PATH[slug.split('/').first] || 'Guide'
      end

      # Multi-symbol API pages open with a `#symbol-index` listing every symbol
      # that is then documented in full further down the same page. Index those
      # symbols individually, then drop the listing: once each symbol has its
      # own entry linking to its section, the listing just repeats the page.
      def additional_entries
        index = at_css('#symbol-index')
        return [] unless index

        entries = index.css('.namespaceItem > .namespaceItemContent > a[href*="#"]')
          .each_with_object([]) do |link, acc|
            target, fragment = link['href'].split('#', 2)
            next if fragment.blank?
            # Symbols re-exported from another module link to the page that
            # documents them; let that page own the entry instead of repeating it.
            next unless target.blank? || target == File.basename(path)
            symbol = link.content.strip
            next if symbol.empty? || acc.any? { |entry| entry.first == symbol }
            acc << [symbol, fragment]
          end

        index.remove
        # The same symbol name is documented by several modules (`Socket` by
        # net, dgram and process); qualify each one with the page it belongs to.
        # For `node:` modules the page title is the import name, so
        # `Profiler.CoverageRange` becomes `Profiler.CoverageRange (inspector)`.
        entries.map! { |symbol, fragment| ["#{symbol} (#{name})", fragment] } if name.present?
        entries
      end
    end
  end
end
