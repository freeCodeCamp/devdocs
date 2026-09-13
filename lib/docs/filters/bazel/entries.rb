module Docs
  class Bazel
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        "Build encyclopedia"
      end

      # Pages that document something other than rules, keyed by what they
      # document. Every other page lists its rules under a "Rules" heading.
      SPECIAL_PAGE_TYPES = {
        'functions' => 'Function',
        'make-variables' => 'Make Variable',
        'common-definitions' => 'Common Definition',
      }

      def additional_entries
        type = SPECIAL_PAGE_TYPES[subpath]

        # Both kinds of page open with a bullet list linking to each of the
        # things they document, which is the only listing they have.
        list = type ? at_css('ul') : at_css('h2#rules + ul')
        return [] if list.nil?

        list.css('> li > a').map do |node|
          [node.content.strip, node['href'].sub('#', ''), type || 'Rule']
        end
      end

    end
  end
end
