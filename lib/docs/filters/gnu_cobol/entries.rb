module Docs
  class GnuCobol
    class EntriesFilter < Docs::EntriesFilter
      # The entire reference is one big page, so get_name and get_type are not necessary

      def additional_entries
        entries = []

        css('.contents > ul > li:not(:last-child)').each do |node|
          parent = node.at_css('a')

          entries << create_entry(parent, parent)

          node.css('ul a').each do |link|
            entries << create_entry(parent, link)
          end
        end

        entries.compact
      end

      def create_entry(parent_link, current_link)
        name = current_link.content
        id = current_link['href'][1..-1]
        type = parent_link.content

        # The navigation link don't actually navigate to the correct header
        # Instead, it references an `a` tag above it
        # The `a` tag it is referencing is removed by a filter further down the pipeline
        # This adds the id to the correct header element
        target_node = at_css("a[name='#{id}']")
        target_node.next_element.next_element['id'] = id

        if name.start_with?('Appendix')
          type = 'Appendices'
        end

        # Everything after Appendix B is removed by the clean_html filter
        ignored_names = [
          'Appendix C - GNU Free Documentation License',
          'Appendix D - Summary of Document Changes',
          'Appendix E - Summary of Compiler Changes since 2009 and version v1-1',
          'Index'
        ]

        ignored_names.include?(name) ? nil : [name, id, type]
      end
    end
  end
end
