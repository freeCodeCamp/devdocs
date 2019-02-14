module Docs
  class Crystal
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('docs/')
          name = at_css('.page-inner h1').content.strip

          if slug.start_with?('docs/syntax_and_semantics')
            name.prepend "#{slug.split('/')[2].titleize}: " if slug.split('/').length > 3
          elsif slug.split('/').length > 1
            chapter = slug.split('/')[1].titleize.capitalize
            name.prepend "#{chapter}: " unless name == chapter
          end

          name
        else
          name = at_css('h1').children.last.content.strip
          name.remove! %r{\(.*\)}
          name
        end
      end

      def get_type
        return if root_page?

        if slug.start_with?('docs/syntax_and_semantics')
          'Book: Language'
        elsif slug.start_with?('docs/')
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
        return [] unless slug.start_with?('api')
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
