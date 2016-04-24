module Docs
  class Numpy
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if dt = at_css('dt')
          name = dt.content.strip
          name.sub! %r{\(.*}, '()'
          name.remove! %r{[\=\[].*}
          name.remove! %r{\A(class(method)?|exception) }
          name.remove! %r{\s—.*}
        else
          name = at_css('h1').content.strip
        end
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        nav_items = css('.nav.nav-pills.pull-left > li')

        if nav_items[3]
          type = nav_items[3].content
        elsif nav_items[2] && nav_items[2].content !~ /Manual|Reference/
          type = nav_items[2].content
        else
          type = at_css('h1').content.strip
          type.remove! "\u{00B6}"

          # Handle some edge cases that arent proberly categorized in the docs
          if type.start_with?('numpy.polynomial.')
            type = 'Polynomials'
          elsif type.start_with?('numpy.ufunc.')
            type = 'Universal functions'
          elsif type.start_with?('numpy.nditer.')
            type = 'Indexing routines'
          elsif type == 'numpy.core.defchararray.chararray.argsort'
            type = 'String operations'
          elsif type == 'numpy.memmap.shape'
            type = 'Input and output'
          elsif type == 'numpy.poly1d.variable'
            type = 'Polynomials'
          end
        end

        type.remove! ' with automatic domain'
        type.remove! %r{\s*\(.*}
        type.capitalize!
        type.sub! 'c-api', 'C API'
        type.sub! 'Numpy', 'NumPy'
        type.sub! 'swig', 'Swig'
        type
      end
    end
  end
end
