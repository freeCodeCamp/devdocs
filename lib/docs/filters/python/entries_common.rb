module Docs
  class Python
    class CommonEntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.remove! %r{\A[\d\.]+ } # remove list number
        name.remove! "\u{00B6}" # remove pilcrow sign
        name.remove! %r{ [\u{2013}\u{2014}].+\z} # remove text after em/en dash
        name.remove! 'Built-in'
        name.strip!
        name
      end

      def get_type
        return 'Logging' if slug.start_with? 'library/logging'

        type = at_css('.related a[accesskey="U"]').content

        original_type = type
        type = parse_type type

        if type == original_type
          if type == 'The Python Standard Library'
            type = at_css('h1').content
          elsif type.include?('I/O') || %w(select selectors).include?(name)
            type = 'Input/ouput'
          end
        end

        type.remove! %r{\A\d+\.\s+} # remove list number
        type.remove! "\u{00b6}" # remove paragraph character
        type.sub! ' and ', ' & '
        [' Services', ' Modules', ' Specific', 'Python '].each { |str| type.remove!(str) }

        self.class.const_get(:REPLACE_TYPES)[type] || type
      end

      def parse_type
        raise Error.new('Python::CommonEntriesFilter is an abstract filter. Subclass it before using it.')
      end

      def include_default_entry?
        !at_css('.body > .section:only-child > .toctree-wrapper:last-child') && type != 'Superseded'
      end

      def additional_entries
        return [] if root_page? || !include_default_entry? || name == 'errno'
        clean_id_attributes
        entries = []

        css('.class > dt[id]', '.exception > dt[id]', '.attribute > dt[id]').each do |node|
          entries << [node['id'], node['id']]
        end

        css('.data > dt[id]').each do |node|
          if node['id'].split('.').last.upcase! # skip constants
            entries << [node['id'], node['id']]
          end
        end

        css('.function > dt[id]', '.method > dt[id]', '.staticmethod > dt[id]', '.classmethod > dt[id]').each do |node|
          entries << [node['id'] + '()', node['id']]
        end

        entries
      end

      def clean_id_attributes
        css('.section > .target[id]').each do |node|
          if dt = node.at_css('+ dl > dt')
            dt['id'] ||= node['id'].remove(/\w+\-/)
          end
          node.remove
        end
      end
    end
  end
end
