module Docs
  class Werkzeug
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SLUG = {}

      def call
        if root_page?
          css('.section').each do |node|
            type = node.at_css('h2').content[0..-2]
            node.css('li > a').each do |n|
              s = n['href'].split('/')[-2]
              TYPE_BY_SLUG[s] = type
            end
          end
        end
        super
      end

      def get_name
        at_css('h1').content[0..-2]
      end

      def get_type
        TYPE_BY_SLUG[slug.split('/').first] || 'Other'
      end

      def additional_entries
        entries = []
        css('dl.function > dt[id]').each do |node|
          name = node['id'].split('.').last + '()'
          id = node['id']
          type = node['id'].split('.')[0..-2].join('.')
          entries << [name, id, type]
        end

        css('dl.class > dt[id]').each do |node|
          name = node['id'].split('.').last
          id = node['id']
          type = node['id'].split('.')[0..-2].join('.')
          entries << [name, id, type]
        end

        css('dl.attribute > dt[id]').each do |node|
          name = node['id'].split('.')[-2..-1].join('.')
          id = node['id']
          type = node['id'].split('.')[0..-3].join('.')
          entries << [name, id, type]
        end

        css('dl.method > dt[id], dl.classmethod > dt[id], dl.staticmethod > dt[id]').each do |node|
          name = node['id'].split('.')[-2..-1].join('.') + '()'
          id = node['id']
          type = node['id'].split('.')[0..-3].join('.')
          entries << [name, id, type]
        end
        entries
      end

    end
  end
end
