module Docs
  class Nokogiri2
    class ContainerFilter < Docs::Rdoc::ContainerFilter
      def call
        return super unless root_page?

        # RDoc no longer generates a table of contents page, and lists the
        # classes in the sidebar navigation instead. Use that list as the root
        # page, both to serve as an index and to make the pages reachable.
        at_css('#classindex-section')
      end
    end
  end
end
