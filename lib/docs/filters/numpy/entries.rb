module Docs
  class Numpy
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if dt = at_css('dt')
          name = dt_to_name(dt)
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

          # Handle some edge cases that aren't properly categorized in the docs
          if type.start_with?('numpy.polynomial.') || type.start_with?('numpy.poly1d.')
            type = 'Polynomials'
          elsif type.start_with?('numpy.ufunc.')
            type = 'Universal functions'
          elsif type.start_with?('numpy.nditer.') || type.start_with?('numpy.lib.Arrayterator.') || type.start_with?('numpy.flatiter.')
            type = 'Indexing routines'
          elsif type.start_with?('numpy.record.') || type.start_with?('numpy.recarray.') || type.start_with?('numpy.broadcast.') || type.start_with?('numpy.matrix.')
            type = 'Standard array subclasses'
          elsif type.start_with?('numpy.busdaycalendar.')
            type = 'Datetime support functions'
          elsif type.start_with?('numpy.random.')
            type = 'Random sampling'
          elsif type.start_with?('numpy.iinfo.')
            type = 'Data type routines'
          elsif type.start_with?('numpy.dtype.')
            type = 'Data type objects'
          elsif type.start_with?('numpy.generic.')
            type = 'Scalars'
          elsif type.start_with?('numpy.char.chararray.') || type.start_with?('numpy.core.defchararray.chararray.')
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

      def additional_entries
        css('dl:not(:first-of-type) > dt[id]').each_with_object [] do |node, entries|
          name = dt_to_name(node)

          if type == 'NumPy C API'
            name = name.rpartition(' ').last
            name = name[2..-1] if name.start_with?('**')
            name = name[1..-1] if name.start_with?('*')
          end

          entries << [name, node['id']]
        end
      end

      def dt_to_name(dt)
        name = dt.content.strip
        name.sub! %r{\(.*}, '()'
        name.remove! %r{[\=\[].*}
        name.remove! %r{\A(class(method)?|exception) }
        name.remove! %r{\s—.*}
        name.remove! '¶'
      end
    end
  end
end
