module Docs
  class Less
    class EntriesFilter < Docs::EntriesFilter
      def name
        at_css('h1').content
      end

      def type
        root_page? ? 'Language' : nil
      end

      def additional_entries
        root_page? ? language_entries : function_entries
      end

      def language_entries
        entries = []

        css('h1').each do |node|
          name = node.content
          entries << [name, node['id']] unless name == 'Overview'
        end

        css('h2[id^="import-options-"]').each do |node|
          entries << ["@import #{node.content}", node['id']]
        end

        entries.concat [
          ['@var',              'variables-feature'],
          ['@{} interpolation', 'variables-feature-variable-interpolation'],
          ['url()',             'variables-feature-urls'],
          ['@property',         'variables-feature-properties'],
          ['@@var',             'variables-feature-variable-names'],
          [':extend()',         'extend-feature'],
          [':extend(all)',      'extend-feature-extend-quotallquot'],
          ['@arguments',        'mixins-parametric-feature-the-codeargumentscode-variable'],
          ['@rest',             'mixins-parametric-feature-advanced-arguments-and-the-coderestcode-variable'],
          ['@import',           'import-directives-feature'],
          ['when',              'mixin-guards-feature'],
          ['.loop()',           'loops-feature'],
          ['+:',                'merge-feature'] ]

        entries
      end

      def function_entries
        entries = []
        type = nil

        css('.docs-section').each do |section|
          if title = section.at_css('h1')
            type = title.content
            type.sub! %r{(\w+) Functions}, 'Functions: \1'
          end

          section.css('h3').each do |node|
            entries << [node.content, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
