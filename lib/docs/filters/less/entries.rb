module Docs
  class Less
    class EntriesFilter < Docs::EntriesFilter
      def name
        at_css('h2').content
      end

      def type
        root_page? ? 'Language' : 'Functions'
      end

      def additional_entries
        root_page? ? language_entries : function_entries
      end

      def language_entries
        entries = []

        css('h2').each do |node|
          name = node.content.strip
          name = 'Rulesets' if name == 'Passing Rulesets to Mixins'
          entries << [name, node['id']] unless name == 'Overview'
        end

        css('h3[id^="import-options-"]').each do |node|
          entries << ["@import #{node.content}", node['id']] unless node.content =~ /example/i
        end

        entries.concat [
          ['@var',              'variables-feature'],
          ['@{} interpolation', 'variables-feature-variable-interpolation'],
          ['url()',             'variables-feature-urls'],
          ['@property',         'variables-feature-properties'],
          ['@@var',             'variables-feature-variable-names'],
          [':extend()',         'extend-feature'],
          [':extend(all)',      'extend-feature-extend-all-'],
          ['@arguments',        'mixins-parametric-feature-the-arguments-variable'],
          ['@rest',             'mixins-parametric-feature-advanced-arguments-and-the-rest-variable'],
          ['@import',           'import-directives-feature'],
          ['when',              'mixin-guards-feature'],
          ['.loop()',           'loops-feature'],
          ['+:',                'merge-feature'] ]

        entries
      end

      def function_entries
        entries = []
        type = nil

        css('*').each do |node|
          if node.name == 'h2'
            type = node.content
            type.sub! %r{(.+) Functions}, 'Functions: \1'
          elsif node.name == 'h3'
            entries << [node.content, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
