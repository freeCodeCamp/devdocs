module Docs
  class DjangoRestFramework
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = css('h1').first.content
        name.slice! 'Tutorial '
        name = '0: ' + name if name.include? 'Quickstart'
        name
      end

      def get_type
        case subpath
        when /\Atutorial/
          'Tutorial'
        when /\Aapi-guide/
          'API Guide'
        end
      end

      def additional_entries
        return [] if type == nil || type == 'Tutorial'

        # Framework classes are provided in two different ways:
        # - as H2's after H1 category titled:
        accepted_headers = ['API Reference', 'API Guide']
        # - as headers (1 or 2) with these endings:
        endings = ['Validator', 'Field', 'View', 'Mixin', 'Default', 'Serializer']

        # To avoid writing down all the endings
        # and to ensure all entries in API categories are matched
        # two different ways of finding them are used

        entries = []

        local_type = 'Ref: ' + name
        in_category = false

        css('h1, h2').each do |node|
          # Third party category contains entries that could be matched (and shouldn't be)
          break if node.content === 'Third party packages'

          if in_category
            if node.name === 'h1'
              in_category = false
              next
            end
            entries << [node.content, node['id'], local_type]
          elsif accepted_headers.include? node.content
            in_category = true
          elsif endings.any? { |word| node.content.ends_with?(word) }
            entries << [node.content, node['id'], local_type]
          end
        end

        entries
      end
    end
  end
end
