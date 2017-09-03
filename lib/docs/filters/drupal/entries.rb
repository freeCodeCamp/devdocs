module Docs
  class Drupal
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('#page-subtitle').content
        name.remove! %r{(abstract|public|static|protected|private|final|function|class|constant|interface|property|global|trait)\s+}
        name
      end

      def get_type
        if subpath =~ /Drupal!Core!([^!]+)!/ ||
           subpath =~ /Drupal!Component!([^!]+)!/ ||
           subpath =~ /core!modules!([^!\/]+)/ ||
           subpath =~ /core!includes!([^!\/]+)/
          $1.underscore
        elsif subpath =~ /Drupal!Core/
          'core'
        elsif subpath =~ /Drupal!Component/
          'component'
        elsif subpath =~ /core!themes/
          'themes'
        else
          css('.breadcrumb > a')[1].content
        end
      end

      def include_default_entry?
        !initial_page?
      end
    end
  end
end
