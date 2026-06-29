module Docs
  class Celery
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.gsub(/\P{ASCII}/, '')
      end

      def get_type
        if subpath.include?('internals/')
          'Internal Module Reference'
        elsif subpath.include?('reference/')
          'API Reference'
        elsif subpath.include?('userguide/')
          'User Guide'
        else
          name
        end
      end

      def additional_entries
        css('dl.py dt[id]').each_with_object [] do |node, entries|
          entries << [node['id'], node['id'], get_type]
        end
      end
    end
  end
end
