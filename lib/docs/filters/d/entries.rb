module Docs
  class D
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.to_s.gsub('_', '.').gsub('/', '.').squish!
      end

      def get_type
        slug.to_s.sub(/_(.*)/, '')
      end

      def additional_entries
        names = []
        css('.book > tr > td > a').each do |x|
          span_block = x.at_css('span')
          if span_block != nil
            elem_name = span_block.text
            name = "#{get_name}.#{elem_name}"
            type = name.sub(/\..*/,'')
            names << [name, "#{slug}#{x['href']}", type]
          end
        end
        names
      end
    end
  end
end
