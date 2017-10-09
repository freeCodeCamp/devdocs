module Docs
  class ReactNative
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'The Basics' => 'Getting Started',
        'apis' => 'APIs',
        'components' => 'Components'
      }

      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def get_type
        link = at_css('.nav-docs-section .active, .toc .active')
        return 'Miscellaneous' unless link
        section = link.ancestors('.nav-docs-section, section').first
        type = section.at_css('h3').content.strip
        type = REPLACE_TYPES[type] || type
        type += ": #{name}" if type == 'Components'
        type
      end

      def additional_entries
        css('.props > .prop > .propTitle', '.props > .prop > .methodTitle').each_with_object [] do |node, entries|
          name = node.children.find(&:text?).try(:content)
          next if name.blank?
          sep = node.content.include?('static') ? '.' : '#'
          name.prepend(self.name + sep)
          name << '()' if node['class'].include?('methodTitle')
          name.remove! %r{\??\:\s*\z}
          id = node.at_css('.anchor')['name']
          entries << [name, id]
        end
      end
    end
  end
end
