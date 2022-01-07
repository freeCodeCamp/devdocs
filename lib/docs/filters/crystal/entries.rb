module Docs
  class Crystal
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if current_url.path.start_with?('/reference/')
          name = at_css('main h1').content.strip
          name.remove! '¶'

          if current_url.path.start_with?('/reference/') && slug.match?('syntax_and_semantics')
            name.prepend "#{slug.split('/')[2].titleize}: " if slug.split('/').length > 3
          elsif slug.split('/').length > 1
            chapter = slug.split('/')[1].titleize.capitalize
            name.prepend "#{chapter}: " unless name == chapter
          end

          name
        else
          return at_css('h1').content.strip unless at_css('.type-name')
          name = at_css('.type-name').children.last.content.strip
          name.remove! %r{\(.*\)}
          name
        end
      end

      def get_type
        return if current_url.path == "/api/#{release}/index.html"

        if current_url.path.start_with?('/reference/') && slug.match?('syntax_and_semantics')
          'Book: Language'
        elsif current_url.path.start_with?('/reference/')
          'Book'
        else
          hierarchy = at_css('.superclass-hierarchy')
          if hierarchy && hierarchy.content.include?('Exception')
            'Exceptions'
          else
            type = at_css('.types-list > ul > .current > a').content
            type = 'Float' if type.start_with?('Float')
            type = 'Int' if type.start_with?('Int')
            type = 'UInt' if type.start_with?('UInt')
            type = 'TCP' if type.start_with?('TCP')
            type
          end
        end
      end

      def additional_entries
        return [] unless current_url.path.start_with?('/api/')
        entries = []

        css('.entry-detail[id$="class-method"]').each do |node|
          name = node.at_css('.signature > strong').content.strip
          name.prepend "#{self.name}." unless slug.end_with?('toplevel')
          id = node['id'] = node['id'].remove(/<.+?>/)
          entries << [name, id] unless entries.last && entries.last[0] == name
        end

        css('.entry-detail[id$="instance-method"]').each do |node|
          name = node.at_css('.signature > strong').content.strip
          name.prepend "#{self.name}#" unless slug.end_with?('toplevel')
          id = node['id'] = node['id'].remove(/<.+?>/)
          entries << [name, id] unless entries.last && entries.last[0] == name
        end

        css('.entry-detail[id$="macro"]').each do |node|
          name = node.at_css('.signature > strong').content.strip
          name.prepend "#{self.name} " unless slug.end_with?('toplevel')
          id = node['id'] = node['id'].remove(/<.+?>/)
          entries << [name, id] unless entries.last && entries.last[0] == name
        end

        entries
      end
    end
  end
end
