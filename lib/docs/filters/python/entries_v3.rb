module Docs
  class Python
    class EntriesV3Filter < Docs::EntriesFilter
      REPLACE_TYPES = {
        'contextvars — Context Variables'          => 'Context Variables',
        'Cryptographic'                            => 'Cryptography',
        'Custom Interpreters'                      => 'Interpreters',
        'Data Compression & Archiving'             => 'Data Compression',
        'email — An email & MIME handling package' => 'Email',
        'Generic Operating System'                 => 'Operating System',
        'Graphical User Interfaces with Tk'        => 'Tk',
        'Internet Data Handling'                   => 'Internet Data',
        'Internet Protocols & Support'             => 'Internet',
        'Interprocess Communication & Networking'  => 'Networking',
        'Program Frameworks'                       => 'Frameworks',
        'Structured Markup Processing Tools'       => 'Structured Markup' }

      def get_name
        name = at_css('h1').content
        name.remove! %r{\A[\d\.]+ } unless include_h2? # remove list number
        name.remove! "\u{00B6}" # remove pilcrow sign
        name.remove! %r{ [\u{2013}\u{2014}].+\z} # remove text after em/en dash
        name.remove! 'Built-in'
        name.strip!
        name
      end

      def get_type
        return 'Language Reference' if slug.start_with? 'reference'
        return 'Python/C API' if slug.start_with? 'c-api'
        return 'Tutorial' if slug.start_with? 'tutorial'
        return 'Software Packaging & Distribution' if slug.start_with? 'distributing'
        return 'Software Packaging & Distribution' if slug.start_with? 'distutils'
        return 'Glossary' if slug.start_with? 'glossary'

        return 'Basics' unless slug.start_with? 'library/'
        return 'Basics' if slug.start_with? 'library/index'

        return 'Logging' if slug.start_with? 'library/logging'
        return 'Asynchronous I/O' if slug.start_with? 'library/asyncio'

        type = at_css('.related a[accesskey="U"]').content

        if type == 'The Python Standard Library'
          type = at_css('h1').content
        elsif type.include?('I/O') || %w(select selectors).include?(name)
          type = 'Input/ouput'
        elsif type.start_with? '19'
          type = 'Internet Data Handling'
        end

        type.remove! %r{\A\d+\.\s+} unless include_h2? # remove list number
        type.remove! "\u{00b6}" # remove paragraph character
        type.sub! ' and ', ' & '
        [' Services', ' Modules', ' Specific', 'Python '].each { |str| type.remove!(str) }

        REPLACE_TYPES[type] || type
      end

      def include_h2?
        return slug.start_with?('library') || slug.start_with?('reference') || slug.start_with?('tutorial') || slug.start_with?('using')
      end

      def include_default_entry?
        return false if slug.starts_with?('genindex')
        return true if slug == 'library/asyncio'
        !at_css('.body > .section:only-child > .toctree-wrapper:last-child') && !type.in?(%w(Superseded))
      end

      def additional_entries
        return additional_entries_index if slug.starts_with?('genindex')
        return [] if root_page? || slug.start_with?('library/index') || !include_default_entry? || name == 'errno'
        clean_id_attributes
        entries = []

        css('.class > dt[id]', '.exception > dt[id]', '.attribute > dt[id]', '.data > dt[id]').each do |node|
          entries << [node['id'], node['id']]
        end

        css('.glossary > dt[id]').each do |node|
          name = node.content.remove("\u{00b6}")
          entries << [name, node['id']]
        end

        css('.function > dt[id]', '.method > dt[id]', '.staticmethod > dt[id]', '.classmethod > dt[id]').each do |node|
          entries << [node['id'] + '()', node['id']]
        end

        if include_h2?
          css('section[id] > h2').each do |node|
            name = node.content.remove("\u{00b6}")
            name.concat " (#{self.name})" if slug.start_with?('library')
            entries << [name, node.parent['id']]
          end
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

      def additional_entries_index
        css('.genindextable td > ul > li').each_with_object [] do |node, entries|
          name = node.children.first
          next unless name.text?
          name = name.text.strip()
          next if name[/Python Enhancement Proposals/]
          node.css('> ul > li > a').each do |inner_node|
            inner_name = inner_node.text.strip()
            next if inner_name[/\[\d+\]/]
            href = inner_node['href']
            next if (name[/^\w/] || name[/^-+\w/]) && !href[/stmts/]
            type = case inner_name
            when 'keyword'
              'Keywords'
            when 'operator'
              'Operators'
            when 'in regular expressions'
              'Regular Expression'
            when /statement/
              'Statements'
            else
              'Symbols'
            end
            entries << ["#{name} (#{inner_name})", href, type]
          end
        end
      end
    end
  end
end
