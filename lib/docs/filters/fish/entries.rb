module Docs
  class Fish
    class EntriesFilter < Docs::EntriesFilter

      def include_default_entry?
        false
      end

      def additional_entries
        css('h2').each_with_object [] do |node, entries|
          name = node.content.split(' - ').first
          id = node['id']
          type = root_page? ? 'Reference' : (slug == 'faq' ? 'FAQ' : slug.capitalize)
          entries << [name, id, type]
        end
      end
    end
  end
end
