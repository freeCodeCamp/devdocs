module Docs
  class Haskell
    class EntriesFilter < Docs::EntriesFilter
      IGNORE_ENTRIES_PATHS = %w(
        Data-ByteString-Lazy.html
        Data-ByteString-Char8.html
        Data-ByteString-Lazy-Char8.html
        Data-Array-IArray.html
        Data-IntMap-Lazy.html
        Data-Map-Lazy.html
        System-Posix-Files-ByteString.html
        System-FilePath-Windows.html
        Control-Monad-Trans-RWS-Lazy.html
        Control-Monad-Trans-State-Lazy.html
        Control-Monad-Trans-Writer-Lazy.html
        GHC-Conc-Sync.html
        GHC-OldList.html
        GHC-IO-Encoding-UTF32.html
        System-Posix-Terminal-ByteString.html
        Text-XHtml-Frameset.html
        Text-XHtml-Strict.html
        System-Posix-Process-ByteString.html
        Data-ByteString-Builder-Prim.html)

      def get_name
        if subpath.start_with?('users_guide')
          name = at_css('h1').content
          name.remove! "\u{00B6}"
          name
        else
          at_css('#module-header .caption').content
        end
      end

      def get_type
        return 'Guide' if subpath.start_with?('users_guide')

        %w(System.Posix System.Win32 Control.Monad).each do |type|
          return type if name.start_with?(type)
        end

        if name.start_with?('Data')
          name.split('.')[0..1].join('.')
        else
          name.split('.').first
        end
      end

      ADD_SUB_ENTRIES_KEYWORDS = %w(class module newtype)

      TYPE_KEYWORDS = %w(class data newtype type)

      def additional_entries
        return [] if subpath.start_with?('users_guide')
        return [] if IGNORE_ENTRIES_PATHS.include?(subpath.split('/').last)

        entry_nodes.each_with_object [] do |node, entries|
          link = node.at_css('a:not([title])')
          name = link.content
          keyword = node.at_css('.keyword').try(:content)

          if ADD_SUB_ENTRIES_KEYWORDS.include?(keyword)
            node.css('.subs > li').each do |sub_node|
              sub_link = sub_node.at_css('a')
              next unless sub_link['href'].start_with?('#')
              sub_name = sub_link.content
              sub_name << " (#{name})"
              entries << [sub_name, sub_link['href'].remove('#')]
            end
          end

          next unless link['href'].start_with?('#') && name != self.name

          # Dozens of modules export a foldr, an insert or a null. Append the
          # type the module is built around, the way the members of a class get
          # the class appended above, so that they stay tellable apart. The
          # declarations of the types themselves read better without it.
          name += " (#{module_type})" if module_type && !TYPE_KEYWORDS.include?(keyword)
          entries << [name, link['href'].remove('#')]
        end
      end

      def include_default_entry?
        subpath.start_with?('users_guide') || entry_nodes.first
      end

      private

      def entry_nodes
        @entry_nodes ||= css('#synopsis > details > ul > li')
      end

      # The type a module is built around: Map for Data.Map.Strict, Text for
      # Data.Text, PosixString for System.OsString.Posix. Haddock lists it as
      # the first type declaration of the synopsis.
      def module_type
        return @module_type if defined?(@module_type)

        node = entry_nodes.find { |n| TYPE_KEYWORDS.include?(n.at_css('.keyword').try(:content)) }
        @module_type = node && node.content.squish[/\A\w+(?: family)? ([A-Z][\w.']*)/, 1]
      end
    end
  end
end
