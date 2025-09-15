module Docs
  class Svg
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = super
        name.gsub!('Attribute.', '')
        name.gsub!('Element.', '')
        name.gsub!('Guides.', '')
        name.gsub!('Reference.', '')
        name.gsub!('Tutorials.', '')
        name.gsub!('_', '')

        if name.in?(%w(Element Attribute Content\ type))
          "#{name}s"
        else
          name
        end
      end

      def get_type
        if slug.start_with?('Reference/Element')
          'Elements'
        elsif slug.start_with?('Reference/Attribute')
          'Attributes'
        elsif slug.start_with?('Guides')
          'Guides'
        elsif slug.start_with?('Tutorials')
          'Tutorials'
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        return [] unless slug == 'Content_type'
        entries = []

        css('h2[id]').each do |node|
          dl = node.next_element
          next unless dl.name == 'dl'
          name = dl.at_css('dt').content.remove(/[<>]/)
          entries << [name, node['id']]
        end

        entries
      end
    end
  end
end
