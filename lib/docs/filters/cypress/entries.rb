# frozen_string_literal: true

module Docs
  class Cypress
    class EntriesFilter < Docs::EntriesFilter
      SECTIONS = %w[
        commands
        core-concepts
        cypress-api
        events
        examples
        getting-started
        guides
        overview
        plugins
        references
        utilities
      ].freeze

      def get_name
        at_css('h1.article-title').content.strip
      end

      def get_type
        path = context[:url].path

        SECTIONS.each do |section|
          if path.match?("/#{section}/")
            return section.split('-').map(&:capitalize).join(' ')
          end
        end
      end

      def additional_entries
        css('.sidebar-li > a').map do |node|
          [node['href']]
        end
      end
    end
  end
end
