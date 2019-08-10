module Docs
  class ScikitLearn
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # Classes, functions and methods
        if subpath.start_with?('modules/generated')
          name = at_css('dt').content.strip
          name.sub! %r{\(.*}, '()' # Remove function arguments
          name.remove! %r{[\=\[].*} # Remove [source] anchor
          name.remove! %r{\A(class(method)?) (sklearn\.)?}
        else
          # User guide
          name = at_css('h1').content.strip
          name.remove! %r{\(.*?\)}
          name.remove! %r{(?<![A-Z]):.*}
          name.prepend 'Tutorial: ' if type == 'Tutorials'
          name.prepend 'Example: ' if type == 'Examples'
        end

        name.remove! "\u{00B6}"
        name
      end

      def get_type
        # Classes, functions and methods
        if subpath.start_with?('modules/generated')
          type = at_css('dt > .descclassname').content.strip
          type.remove! 'sklearn.'
          type.remove! %r{\.\z}
          type = 'sklearn' if type.blank?
          type
        elsif subpath.start_with?('tutorial')
          'Tutorials'
        elsif subpath.start_with?('auto_examples')
          'Examples'
        else
          'Guide'
        end
      end

      def additional_entries
        return [] unless subpath.start_with?('modules/generated')
        entries = []

        css('.class > dt[id]', '.exception > dt[id]', '.attribute > dt[id]').each do |node|
          entries << [node['id'].remove('sklearn.'), node['id']]
        end

        css('.data > dt[id]').each do |node|
          if node['id'].split('.').last.upcase! # skip constants
            entries << [node['id'].remove('sklearn.'), node['id']]
          end
        end

        css('.function > dt[id]', '.method > dt[id]', '.classmethod > dt[id]').each do |node|
          entries << [node['id'].remove('sklearn.') + '()', node['id']]
        end

        entries
      end
    end
  end
end
