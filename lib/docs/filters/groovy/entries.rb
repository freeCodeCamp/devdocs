module Docs
  class Groovy
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.split('/').last
      end

      def get_type
        slug.split('/')[0..-2].join('.')
      end

      def include_default_entry?
        slug.split('/').last != 'package-summary'
      end

      def additional_entries
        entries = []
        css('.method, .element, .field, .enum_constant').each do |node|
          entries << [@name + '.' + node['id'], node['id']]
        end
        css('.constructor').each do |node|
          entries << [node['id'], node['id']]
        end
        entries
      end
    end
  end
end
