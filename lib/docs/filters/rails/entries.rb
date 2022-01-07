module Docs
  class Rails
    class EntriesFilter < Docs::EntriesFilter# Docs::Rdoc::EntriesFilter
      def get_name
        if current_url.to_s.match?('guides')
          at_css('h2').content
        else
          name = at_css('h2').to_html.scan(/<\/span>.*?</)[0]

          if name.nil?
            name = at_css('h2').content
          else
            name.sub!("<\/span>", '')
            name.sub!('<', '')
          end

          name.strip
        end
      end

      def get_type
        return 'Guides' if current_url.to_s.match?('guides')
        return 'Ruby files' if name =~ /.rb/

        name.split('::')[0]

      end

      def additional_entries
        return [] if current_url.to_s.match?('guides')

        entries = []

        css('.title.method-title').each do |node|
          entry_name = node.at_css('b').content
          entries << [name+"##{entry_name}", node['id']]
        end

        entries
      end

    end
  end
end
