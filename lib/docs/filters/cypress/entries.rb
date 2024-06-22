# frozen_string_literal: true

module Docs
  class Cypress
    class EntriesFilter < Docs::EntriesFilter
      SECTIONS = %w[
        commands
        core-concepts
        cypress-api
        events
        getting-started
        guides
        overview
        plugins
        references
        utilities
      ].freeze

      def get_name
        at_css('h1.main-content-title').content.strip
      end

      def get_type
        path = context[:url].path

        SECTIONS.each do |section|
          if path.match?("/#{section}/")
            return section.split('-').map(&:capitalize).join(' ')
          end
        end
      end
    end
  end
end
