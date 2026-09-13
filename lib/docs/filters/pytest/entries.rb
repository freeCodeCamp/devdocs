module Docs
  class Pytest
    class EntriesFilter < Docs::EntriesFilter
      # The documentation follows the Diátaxis framework, which its URLs mirror
      TYPE_BY_DIRECTORY = {
        'how-to' => 'How-to guides',
        'reference' => 'Reference',
        'explanation' => 'Explanation',
        'example' => 'Examples'
      }

      # The only page documenting objects; its second-level sections (Functions,
      # Marks, Fixtures, Hooks, ...) are used as the types of those objects
      API_REFERENCE_SLUG = 'reference/reference'

      # Objects are documented under the module implementing them, which is part
      # of neither pytest's public API nor of the names shown in the signatures
      PRIVATE_MODULE = /\Apytest\.(?:capture|doctest|fixtures|hookspec|junitxml|logging|monkeypatch|nodes|python|recwarn|tmpdir)\./

      CALLABLE = /\b(?:function|method|classmethod|staticmethod)\b/

      def get_name
        at_css('h1').content.strip
      end

      def get_type
        TYPE_BY_DIRECTORY[slug.split('/').first] || 'Get Started'
      end

      def additional_entries
        return [] unless slug == API_REFERENCE_SLUG

        entries = []

        css('> section').each do |section|
          next unless heading = section.at_css('> h2')
          type = heading.content.strip

          section.css('dl.py > dt[id], dl.std > dt[id]').each do |node|
            entries << [object_name(node), node['id'], type]
          end

          # Constants and a few other objects (e.g. custom marks) are documented
          # as plain sections rather than as Sphinx objects
          section.css('> section').each do |subsection|
            next if subsection.at_css('dl.py > dt[id], dl.std > dt[id]')
            next unless subheading = subsection.at_css('> h3')
            entries << [subheading.content.strip, subsection['id'], type]
          end
        end

        entries
      end

      private

      def object_name(node)
        classes = node.parent['class']

        # Configuration options, command-line flags, environment variables and
        # global variables have prefixed ids (e.g. "confval-addopts"), the
        # signature is the only place where they appear as one writes them
        return node.at_css('.descname').content.strip if classes.include?('std')

        name = node['id'].sub(PRIVATE_MODULE, '')
        name << '()' if classes =~ CALLABLE
        name
      end
    end
  end
end
