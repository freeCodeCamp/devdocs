module Docs
  class Numpy
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        dt = at_css('dt')
        if dt
          name = dt.content
          name.sub! /\(.*/, '()'
          name.sub! /[\=\[].*/, ''
          name.remove! 'class '
          name.remove! 'classmethod '
          name.remove! 'exception '
        else
          name = at_css('h1').content.strip
        end
        name.remove! '¶' # remove permalinks from title
        name
      end

      def get_type
        type = name.dup
        nav_items = at_css('.nav.nav-pills.pull-left').children
        if nav_items[7]
          # Infer type from navigation item if possible...
          type = nav_items[7].content
        else
          # ... or the page is probably an overview, so use its title.
          type = at_css('h1').content
          type.remove! '¶' # remove permalinks from type

          # Handle some edge cases that arent proberly categorized in the docs
          if type[0..16] == 'numpy.polynomial.'
            type = 'Polynomials'
          elsif type[0..11] == 'numpy.ufunc.'
            type = 'Universal functions (ufunc)'
          elsif type[0..12] == 'numpy.nditer.'
            type = 'Indexing routines'
          elsif type == 'numpy.core.defchararray.chararray.argsort'
            type = 'String operations'
          elsif type == 'numpy.memmap.shape'
            type = 'Input and output'
          elsif type == 'numpy.poly1d.variable'
            type = 'Polynomials'
          end
        end
        type
      end
    end
  end
end
