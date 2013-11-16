module Docs
  class Rdoc
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.sub! 'class ', ''
        name.sub! 'module ', ''
        name
      end

      def get_type
        type = name.dup

        unless type.sub! %r{::.*\z}, ''
          parent = at_css('.meta-parent').try(:content).to_s.strip
          return 'Errors' if type.end_with?('Error') || parent.end_with?('Error') || parent.end_with?('Exception')
        end

        type
      end

      def additional_entries
        return [] if root_page?
        require 'cgi'

        css('.method-detail').map do |node|
          name = node['id'].dup
          name.sub! %r{\A\w+?\-.}, ''
          name.sub! %r{\A-(?!\d)}, ''
          name.gsub! '-', '%'
          name = CGI.unescape(name)
          name.prepend self.name + (node['id'] =~ /\A\w+-c-/ ? '::' : '#')
          [name, node['id']]
        end
      end
    end
  end
end
