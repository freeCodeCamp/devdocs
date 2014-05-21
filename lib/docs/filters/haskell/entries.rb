module Docs
  class Haskell
    class EntriesFilter < Docs::EntriesFilter

      # gets name and type in one fell swoop
      # 
      # eg.
      #  Control.Monad > [Monad, Control]
      #  Control.Concurrent.Mvar > [Concurrent.MVar, Control]
      #  Array > [Array, nil]
      def get_name_and_type
        if at_css('h1') && at_css('h1').content == 'Haskell Hierarchical Libraries'
          name = 'Haskell'
          type = nil
        else
          # find full module identifier
          caption = at_css('#module-header .caption')

          if caption
            # split the module path
            parts   = caption.content.split('.')

            if parts.length > 1
              # if more than one part then the 
              # first is the type and the rest is the name
              type = parts[0]
              name = parts.drop(1).join('.')
            else
              # if only one part, this is the name
              name = parts[0]
              type = nil
            end
          else
            # no caption found -> no type / no name
            name = 'no-name'
            type = 'no-type'
          end
        end
        [name, type]
      end

      # get the name
      def get_name
        n, t = get_name_and_type()
        n
      end

      # get the type
      def get_type
        n, t = get_name_and_type()
        t
      end

    end
  end
end
