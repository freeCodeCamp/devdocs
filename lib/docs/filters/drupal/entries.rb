module Docs
  class Drupal
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('#page-subtitle').content
        name.remove! %r{(abstract|public|static|protected|final|function|class)\s+}
        name
      end

      def get_type
        type = css('.breadcrumb > a')[1].content.strip
        type.split('.').first
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
