module Docs
  class Babel
    class EntriesFilter < Docs::EntriesFilter

      ENTRIES = {
        'Usage' => ['Options', 'Config Files', '@babel/cli', '@babel/polyfill',
                    '@babel/plugin-transform-runtime', '@babel/register'],

        'Presets' => ['@babel/preset-env', '@babel/preset-flow', '@babel/preset-react', '@babel/preset-typescript'],

        'Tooling' => ['@babel/parser', '@babel/core', '@babel/generator', '@babel/code-frame',
                      '@babel/helpers', '@babel/runtime', '@babel/template', '@babel/traverse', '@babel/types']
      }

      def get_name
        at_css('h1').content
      end

      def get_type
        ENTRIES.each do |key, value|
          return key if value.include?(name)
          return 'Other Plugins' if subpath.include?('babel-plugin')
        end
      end

    end
  end
end
