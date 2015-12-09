module Docs
  class Codeigniter
    class EntriesFilter < Docs::EntriesFilter
      def include_default_entry?
        not slug.ends_with? 'index'
      end

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        slug.split('/')[0].capitalize
      end

      def additional_entries
        entries = []

        css('.class').each do |c_node|
          c_name = c_node.at_css('dt > .descname').content
          c_id = c_node.at_css('dt')['id']
          entries << [c_name, c_id, get_type]

          c_node.css('.method').each do |node|
            m_name = node.at_css('.descname').content
            name = c_name + '::' + m_name + '()'
            id = node.at_css('dt')['id']
            entries << [name, id, get_type]
          end
        end

        css('.function').each do |node|
          name = node.at_css('.descname').content + '()'
          id = node.at_css('dt')['id']
          entries << [name, id, get_type]
        end

        entries
      end
    end
  end
end
