module Docs
  class Click
    class EntriesFilter < Docs::EntriesFilter
      TYPE_BY_SLUG = {}

      def call
        if root_page?
          css('section').each do |node|
            next if ['documentation', 'api-reference'].include?(node['id'])
            type = node.at_css('h2').content.strip
            node.css('li > a').each do |toclink|
              slug = toclink['href'].split('/')[-2]
              TYPE_BY_SLUG[slug] = type
            end
          end
        end
        super
      end

      def get_name
        return at_css('h1').content.strip
      end

      def get_type
        TYPE_BY_SLUG[slug.split('/').first] || at_css('h1').content.strip
      end

      def include_default_entry?
        TYPE_BY_SLUG.include?(slug.split('/').first)
      end

      def additional_entries
        return [] if root_page? || TYPE_BY_SLUG.include?(slug.split('/').first)

        if slug == 'api/'
          entries = []
          doc.css('> section').each do |section|
            title = section.at_css('h2').content.strip
            section.css('dl.py > dt[id]').each do |dt|
              name = dt['id'].split('.')[1..].join('.')
              name << '()' if dt.parent.classes.intersect?(['function', 'method', 'classmethod', 'staticmethod'])
              entries << [name, dt['id'], title]
            end
          end
          return entries
        end

        (doc.css('> section') || []).map do |section|
          title = section.at_css('h2').content.strip
          [title, section['id']]
        end
      end

      private

    end
  end
end
