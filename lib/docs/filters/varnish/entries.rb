module Docs
  class Varnish
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
        case slug
        when /installation/
          'Installation'
        when /users-guide/
          'Users Guide'
        when /tutorial/
          'Tutorial'
        when /reference/
          'Reference Manual'
        when /dev-guide/
          'Dev Guide'
        else
          TYPE_BY_SLUG[slug.split('/').first] || 'Other'
        end
      end

      def include_default_entry?
        slug != 'reference/'
      end

      def additional_entries
        entries = []

        css('dl.class > dt[id]').each do |node|
          name = node['id'].split('.').last
          id = node['id']
          type = node['id'].split('.')[0..-2].join('.')
          entries << [name, id, type]
        end


        entries
      end

    end
  end
end
