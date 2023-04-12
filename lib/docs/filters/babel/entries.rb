module Docs
  class Babel
    class EntriesFilter < Docs::EntriesFilter

      ENTRIES = {
        'Usage' => ['Options', 'Plugins', 'Config Files', 'Compiler assumptions', '@babel/cli', '@babel/polyfill',
                    '@babel/plugin-transform-runtime', '@babel/register'],

        'Presets' => ['@babel/preset'],

        'Tooling' => ['@babel/parser', '@babel/core', '@babel/generator', '@babel/code-frame',
                      '@babel/helper', '@babel/runtime', '@babel/template', '@babel/traverse', '@babel/types', '@babel/standalone']
      }

      def get_name
        at_css('h1').content
      end

      def get_type
        ENTRIES.each do |key, value|
          return key if value.any? { |val| name.start_with?(val) }
          return 'Other Plugins' if subpath.include?('babel-plugin')
        end
      end

    end
  end
end
