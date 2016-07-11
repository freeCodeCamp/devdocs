module Docs
  class Drupal
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('#page-subtitle').content
        name.remove! %r{(abstract|public|static|protected|final|function|class|constant|interface|property|global)\s+}
        name
      end

      def get_type
        links = css('.breadcrumb > a')
        type = links.length > 1 ? links[1].content.strip : name
        type.split(/[\.\-]/).first
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
