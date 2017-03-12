module Docs
  class Matplotlib
    class EntriesFilter < Docs::EntriesFilter
      NAME_BY_SLUG = {
        'matplotlib_configuration_api' => 'matplotlib',
        'tri_api' => 'tri'
      }

      TYPE_BY_SLUG = {
        'pyplot_summary' => 'pyplot'
      }

      def get_name
        return NAME_BY_SLUG[slug] if NAME_BY_SLUG.key?(slug)
        name = at_css('h1').content.strip
        name.remove! "\u{00b6}"
        name.remove! 'matplotlib.'
        name.remove! 'mpl_toolkits.'
        name.remove! ' API'
        name.remove! %r{ \(.*\)}
        name
      end

      def get_type
        return TYPE_BY_SLUG[slug] if TYPE_BY_SLUG.key?(slug)
        type = name.split('.').first
        type.downcase!
        type.remove! ' module'
        type.remove! ' class'
        type
      end

      def additional_entries
        entries = []

        css('.class > dt[id]', '.exception > dt[id]', '.attribute > dt[id]').each do |node|
          entry_name = node['id'].remove('matplotlib.').remove('mpl_toolkits.')
          entries << [entry_name, node['id']] unless entry_name.casecmp(name) == 0
        end

        css('.data > dt[id]').each do |node|
          if node['id'].split('.').last.upcase! # skip constants
            entry_name = node['id'].remove('matplotlib.').remove('mpl_toolkits.')
            entries << [entry_name, node['id']] unless entry_name.casecmp(name) == 0
          end
        end

        css('.function > dt[id]', '.method > dt[id]', '.classmethod > dt[id]').each do |node|
          entry_name = node['id'].remove('matplotlib.').remove('mpl_toolkits.')
          entries << [entry_name + '()', node['id']] unless entry_name.casecmp(name) == 0
        end

        entries
      end
    end
  end
end
