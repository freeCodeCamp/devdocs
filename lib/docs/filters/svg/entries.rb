module Docs
  class Svg
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = super
        name.gsub!('Element.', '').try(:downcase!)
        name.gsub!('Attribute.', '').try(:downcase!)
        name.gsub!('Tutorial.', '')
        name.gsub!('_', '')

        if name.in?(%w(Element Attribute Content\ type))
          "#{name}s"
        else
          name
        end
      end

      def get_type
        if slug.start_with?('Element')
          'Elements'
        elsif slug.start_with?('Attribute')
          'Attributes'
        elsif slug.start_with?('Tutorial')
          'Tutorial'
        elsif slug == 'Content_type'
          'Content types'
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
