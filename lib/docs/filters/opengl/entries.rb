module Docs
  class Opengl
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.chomp('.xhtml').chomp('.xml')
      end

      # gl4 also has documentation of GLSL, this string is present under Version Support
      def get_type
        return 'GLSL' if html.include?('OpenGL Shading Language Version')
        'OpenGL'
      end

      # functions like glUniform1f, glUniform2f, glUniform... have the same documentation
      def additional_entries
        entries = []
        css('.fsfunc').each do |function|
          next if function.text == name
          entries << [ function.text, function.text ]
        end
        entries
      end
    end
  end
end
