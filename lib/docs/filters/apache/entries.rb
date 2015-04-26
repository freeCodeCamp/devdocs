module Docs
  class Apache
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug == 'mod/'
          'Modules'
        elsif slug == 'programs/'
          'Programs'
        elsif slug == 'mod/core'
          'core'
        else
          name = at_css('h1').content.strip
          name.remove! %r{\ Support\z}i
          name.remove! %r{in\ Apache\z}
          name.remove! %r{\ documentation\z}i
          name.remove! %r{\AApache\ (httpd\ )?(Tutorial:\ )?}i
          name.remove! 'HTTP Server Tutorial: '
          name.sub! 'Module mod_', 'mod_'
          name.remove! %r{\ \-.*} if slug.start_with?('programs')
          name
        end
      end

      def get_type
        if slug.start_with?('howto')
          'Tutorials'
        elsif slug.start_with?('platform')
          'Platform Specific Notes'
        elsif slug.start_with?('programs')
          'Programs'
        elsif slug.start_with?('misc')
          'Miscellaneous'
        elsif slug.start_with?('mod/')
          'Modules'
        elsif slug.start_with?('ssl/')
          'Guide: SSL/TLS'
        elsif slug.start_with?('rewrite/')
          'Guide: Rewrite'
        elsif slug.start_with?('vhosts/')
          'Guide: Virtual Host'
        else
          'Guide'
        end
      end

      def additional_entries
        css('.directive-section > h2').each_with_object [] do |node, entries|
          name = node.content.strip
          next unless name.sub!(/\ Directive\z/, '')
          name.prepend "#{self.name.start_with?('MPM') ? 'MPM' : self.name}: "
          entries << [name, node['id'], 'Directives']
        end
      end
    end
  end
end
