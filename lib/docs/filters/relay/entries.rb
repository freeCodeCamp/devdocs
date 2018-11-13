module Docs
  class Relay
    class EntriesFilter < Docusaurus::EntriesFilter
      def additional_entries
        # TODO: This doesn’t work right. The API seems to have changed significantly.
        # I don’t know Relay so I don’t know what’s important.
        # entries = []
        #
        # css('h3, h4').each do |node|
        #   subname = node.text
        #   next if subname.blank? || node.css('code').empty?
        #   subname.remove! %r{\:\s*[?\w]+}
        #   subname.strip!
        #
        #   id = node['id']
        #   entries << [subname, id]
        # end
        #
        # css('.apiIndex a pre').each do |node|
        #   next unless node.parent['href'].start_with?('#')
        #   id = node.parent['href'].remove('#')
        #   name = node.content.strip
        #   sep = name.start_with?('static') ? '.' : '#'
        #   name.remove! %r{(abstract|static) }
        #   name.sub! %r{\(.*\)}, '()'
        #   name.prepend(self.name + sep)
        #   entries << [name, id]
        # end
        #
        # entries
      end
    end
  end
end
