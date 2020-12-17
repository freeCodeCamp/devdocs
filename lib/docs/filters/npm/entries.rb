module Docs
  class Npm
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type
        at_css('.active').content
      end

      def additional_entries
        entries = []

        if name == 'config'
          css('h4').each do |node|
            entries << [node['id'],  slug + '#' + node['id'], 'Config Settings']
          end
        end

        if name == 'package.json'
          css('h3').each do |node|
            entries << [node['id'],  slug + '#' + node['id'], 'Package.json Settings']
          end
        end

        entries
      end

    end
  end
end
