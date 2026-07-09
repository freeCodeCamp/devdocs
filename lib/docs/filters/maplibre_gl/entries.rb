module Docs
  class MaplibreGl
    class EntriesFilter < Docs::EntriesFilter
      # Sections of a TypeDoc class page whose members are worth indexing
      # individually.
      MEMBER_SECTIONS = %w(Constructors Properties Methods Events Accessors).freeze

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        # DevDocs lower-cases paths, so match against the lower-cased segments.
        case path
        when %r{api/classes/}      then 'Classes'
        when %r{api/functions/}    then 'Functions'
        when %r{api/type-aliases/} then 'Type Aliases'
        when %r{api/interfaces/}   then 'Interfaces'
        when %r{api/enumerations/} then 'Enumerations'
        when %r{api/variables/}    then 'Variables'
        when %r{\Aguides/}         then 'Guides'
        else 'Miscellaneous'
        end
      end

      def additional_entries
        return [] unless class_page?

        entries = []
        section = nil

        css('h2, h3').each do |node|
          if node.name == 'h2'
            section = node.content.strip
          elsif MEMBER_SECTIONS.include?(section)
            member = node.content.strip.sub(/\(\)\z/, '').sub(/\?\z/, '')
            next if member.empty?
            entries << ["#{get_name}.#{member}", "#{path}##{node['id']}"]
          end
        end

        entries
      end

      private

      def class_page?
        path.include?('api/classes/')
      end
    end
  end
end
