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
        at_css('#module-header .caption').content.strip
      end

      def get_type
        %w(System.Posix System.Win32 Control.Monad).each do |type|
          return type if name.start_with?(type)
        end

        if name.start_with?('Data')
          name.split('.')[0..1].join('.')
        else
          name.split('.').first
        end
      end

      def additional_entries
        return [] if IGNORE_ENTRIES_PATHS.include?(subpath.split('/').last)

        css('#synopsis > ul > li').each_with_object [] do |node, entries|
          link = node.at_css('a')
          next unless link['href'].start_with?('#')
          name = node.content.strip
          name.remove! %r{\A(?:module|data|newtype|class|type family m|type)\s+}
          name.sub! %r{\A\((.+?)\)}, '\1'
          name.sub!(/ (?:\:\: (\w+))?.*\z/) { |_| $1 ? " (#{$1})" : '' }
          next if name == self.name
          entries << [name, link['href'].remove('#')]
        end
      end

      def include_default_entry?
        at_css('#synopsis > ul > li')
      end
    end
  end
end
