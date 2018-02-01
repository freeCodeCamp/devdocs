module Docs
  class Babel
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.sub /^(minify|syntax)|(transform|preset)$/i, ''
      end

      def get_type
        if subpath.start_with? 'plugins/preset'
          'Presets'
        elsif subpath.start_with? 'plugins/transform'
          'Transform Plugins'
        elsif subpath.start_with? 'plugins/minify'
          'Minification'
        elsif subpath.start_with? 'plugins/syntax'
          'Syntax Plugins'
        elsif subpath.start_with? 'plugins'
          'Plugins'
        elsif subpath.start_with? 'usage/'
          'Usage'
        else
          'Docs'
        end
      end

      def path
        super
      end
    end
  end
end
