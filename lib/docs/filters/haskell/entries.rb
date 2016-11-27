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

      def additional_entries
        return [] if subpath.start_with?('users_guide')
        return [] if IGNORE_ENTRIES_PATHS.include?(subpath.split('/').last)

        css('#synopsis > ul > li').each_with_object [] do |node, entries|
          link = node.at_css('a')
          name = node.content.strip
          name.remove! %r{\A(?:module|data|newtype|class|type family m|type)\s+}
          name.sub! %r{\A\((.+?)\)}, '\1'
          name.sub!(/ (?:\:\: (\w+))?.*\z/) { |_| $1 ? " (#{$1})" : '' }

          if ADD_SUB_ENTRIES_KEYWORDS.include?(node.at_css('.keyword').try(:content))
            node.css('.subs > li').each do |sub_node|
              sub_link = sub_node.at_css('a')
              next unless sub_link['href'].start_with?('#')
              sub_name = sub_node.content.strip
              sub_name.remove! %r{\s.*}
              sub_name.prepend "#{name} "
              entries << [sub_name, sub_link['href'].remove('#')]
            end
          end

          entries << [name, link['href'].remove('#')] if link['href'].start_with?('#') && name != self.name
        end
      end

      def include_default_entry?
        subpath.start_with?('users_guide') || at_css('#synopsis > ul > li')
      end
    end
  end
end
