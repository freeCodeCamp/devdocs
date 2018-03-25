module Docs
  class Wordpress
    class EntriesFilter < Docs::EntriesFilter
      def breadcrumbs
        @breadcrumbs ||= css('.breadcrumbs .trail-inner a')
                         .map(&:content)
                         .map(&:strip)
      end

      def get_name
        at_css('.breadcrumbs .trail-end').content
      end

      def get_type
        if subpath.starts_with?('classes')
          'Classes'
        elsif subpath.starts_with?('hooks')
          'Hooks'
        elsif subpath.starts_with?('functions')
          'Functions'
        elsif breadcrumbs.size > 1
          breadcrumbs.drop(1).join(': ')
        else
          at_css('.breadcrumbs .trail-end').content
        end
      end
    end
  end
end