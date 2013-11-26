module Docs
  class Python
    class EntriesFilter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'Cryptographic'                           => 'Cryptography',
        'Custom Interpreters'                     => 'Interpreters',
        'Data Compression & Archiving'            => 'Data Compression',
        'Generic Operating System'                => 'Operating System',
        'Graphical User Interfaces with Tk'       => 'Tk',
        'Internet Data Handling'                  => 'Internet Data',
        'Internet Protocols & Support'            => 'Internet',
        'Interprocess Communication & Networking' => 'Networking',
        'Program Frameworks'                      => 'Frameworks',
        'Structured Markup Processing Tools'      => 'Structured Markup' }

      def get_name
        name = at_css('h1').content
        name.sub! %r{\A[\d\.]+ }, ''    # remove list number
        name.sub! %r{ \u{2014}.+\z}, '' # remove text after em dash
        name
      end

      def get_type
        return 'Logging' if slug.start_with? 'library/logging'

        type = at_css('.related a[accesskey="U"]').content

        if type == 'The Python Standard Library'
          type = at_css('h1').content
        elsif type.start_with? '19'
          type = 'Internet Data Handling'
        end

        type.sub! %r{\A\d+\.\s+}, '' # remove list number
        type.sub! "\u{00b6}", ''     # remove paragraph character
        type.sub! ' and ', ' & '
        [' Services', ' Modules', ' Specific', 'Python '].each { |str| type.sub! str, '' }

        REPLACE_TYPES[type] || type
      end

      def include_default_entry?
        name !~ /[A-Z]/ && !skip? # skip non-module names
      end

      def additional_entries
        return [] if root_page? || skip? || name == 'errno'
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

        css('.function > dt[id]', '.method > dt[id]', '.classmethod > dt[id]').each do |node|
          entries << [node['id'] + '()', node['id']]
        end

        entries
      end

      def skip?
        type == 'Language'
      end

      def clean_id_attributes
        css('.section > .target[id]').each do |node|
          if dt = node.at_css('+ dl > dt')
            dt['id'] ||= node['id'].sub(/\w+\-/, '')
          end
          node.remove
        end
      end
    end
  end
end
