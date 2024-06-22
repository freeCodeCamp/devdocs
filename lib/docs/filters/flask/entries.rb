module Docs
  class Flask
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
        when /deploying/
          'User\'s Guide: Deploying'
        when /patterns/
          'User\'s Guide: Design Patterns'
        else
          TYPE_BY_SLUG[slug.split('/').first] || 'Other'
        end
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
          type = 'flask' if type == ''
          entries << [name, id, type]
        end

        css('dl.data > dt[id]').each do |node|
          name = node['id']
          id = node['id']
          type = node['id'].split('.')[0..-3].join('.')
          type = 'flask' if type == ''
          type = 'Configuration' if slug == 'config/'
          entries << [name, id, type]
        end

        css('dl.method > dt[id]').each do |node|
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
