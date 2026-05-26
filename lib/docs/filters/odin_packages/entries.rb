module Docs
  class OdinPackages
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        breadcrumbs = css(".pkg-breadcrumb > ol > li")
        if breadcrumbs
          if breadcrumbs[1]
            breadcrumbs[1].content
          elsif breadcrumbs[0]
            breadcrumbs[0].content
          end
        end
        title = context[:html_title].gsub(/- pkg.odin-lang.org/, "")
        title = title.gsub(/^package /, "")
        title
      end

      def get_type
        breadcrumb_base = css(".pkg-breadcrumb > ol > li")
        doc_directory = css(".doc-directory")
        if breadcrumb_base[0]
          breadcrumb_base[0].content
        elsif doc_directory
          title = context[:html_title].gsub(/ library - pkg.odin-lang.org/, "")
          title
        elsif context[:html_title].starts_with?('package')
          'Packages'
        else
          'Docs'
        end
      end

      def additional_entries
        entries = []
        entries
      end
    end
  end
end

