module Docs
  class ScikitImage
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00b6}"

        if slug.start_with?('api')
          name.remove! 'Module: '
          name.remove! %r{ \(.*\)}
          name.downcase!
        end

        name
      end

      def get_type
        if slug.start_with?('api')
          name.split('.').first
        else
          'Guide'
        end
      end

      def additional_entries
        return [] unless slug.start_with?('api')

        entries = []

        css('.class > dt[id]', '.exception > dt[id]', '.attribute > dt[id]').each do |node|
          entries << [node['id'].remove('skimage.'), node['id']]
        end

        css('.data > dt[id]').each do |node|
          if node['id'].split('.').last.upcase!
            entries << [node['id'].remove('skimage.'), node['id']]
          end
        end

        css('.function > dt[id]', '.method > dt[id]', '.classmethod > dt[id]').each do |node|
          entries << [node['id'].remove('skimage.') + '()', node['id']]
        end

        entries
      end

      def include_default_entry?
        slug != 'api/api'
      end
    end
  end
end
