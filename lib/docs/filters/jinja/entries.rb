module Docs
  class Jinja
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content[0..-2]
      end

      def get_type
        'User Guide'
      end

      def include_default_entry?
        slug != 'api/'
      end

      def additional_entries
        entries = []
        css('dl.function > dt[id]').each do |node|
          name = node['id'].split('.').last + '()'
          id = node['id']
          type = node['id'].split('.')[0..-2].join('.')
          type = 'Template Language' if slug == 'templates/'
          entries << [name, id, type]
        end

        css('dl.class > dt[id], dl.exception > dt[id]').each do |node|
          name = node['id'].split('.').last
          id = node['id']
          type = node['id'].split('.')[0..-2].join('.')
          type = 'Template Language' if slug == 'templates/'
          entries << [name, id, type]
        end

        css('dl.attribute > dt[id], dl.property > dt[id]').each do |node|
          name = node['id'].split('.')[-2..-1].join('.')
          id = node['id']
          type = node['id'].split('.')[0..-3].join('.')
          type = 'Template Language' if slug == 'templates/'
          entries << [name, id, type]
        end

        css('dl.method > dt[id]').each do |node|
          name = node['id'].split('.')[-2..-1].join('.') + '()'
          id = node['id']
          type = node['id'].split('.')[0..-3].join('.')
          type = 'Template Language' if slug == 'templates/'
          entries << [name, id, type]
        end
        entries
      end

    end
  end
end
