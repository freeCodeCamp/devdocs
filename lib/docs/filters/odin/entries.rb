module Docs
  class Odin
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if base_url.host == 'odin-lang.org'
          title = context[:html_title].gsub(/ \| Odin Programming Language/, "")
          title
        else
          breadcrumbs = css(".pkg-breadcrumb > ol > li")
          if breadcrumbs
            if breadcrumbs[1]
              breadcrumbs[1].content
            elsif breadcrumbs[0]
              breadcrumbs[0].content
            end
          end

          title = context[:html_title].gsub(/ - pkg.odin-lang.org/, "")
          title = title.gsub(/^package /, "")
          
          # For the package index page, use the angle bracket
          # to propel the entry to the top 
          if title and title.end_with?("library")
            "- package index"
          else
            title
          end
        end
      end

      def get_type
        if base_url.host == 'odin-lang.org'
          "Documentation"
        elsif base_url.host == 'pkg.odin-lang.org'
          base_package_name = subpath.gsub(/\/.*/, "")
          "Packages / " + base_package_name
        end
      end

      def additional_entries
        entries = []
        entries
      end
    end
  end
end

