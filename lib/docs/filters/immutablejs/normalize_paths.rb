module Docs
  class Immutablejs
    class NormalizePathsFilter < Docs::NormalizePathsFilter
      #
      # Checks if the given url starts with:
      # "#" or ".#", with means it's a fragment url
      #
      FRAGMENT_REGEX = /^(\.)?#/

      def path
        #
        # If we have fragment, we want to use as our path.
        #
        if current_url.fragment
          # Remove "/" from the start
          @path = current_url.fragment.sub(/^\//, '')
        end

        super
      end

      def normalize_href href
        return href.gsub(FRAGMENT_REGEX, '') if href =~ FRAGMENT_REGEX
        super
      end
    end
  end
end
