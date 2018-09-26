module Docs
  class SaltStack
    class EntriesFilter < Docs::EntriesFilter
      SALT_REF_RGX = /salt\.([^\.]+)\.([^\s]+)/

      def get_name
        header = at_css('h1').content

        ref_match = SALT_REF_RGX.match(header)
        if ref_match
          ns, mod = ref_match.captures
          "#{ns}.#{mod}"
        else
          header
        end
      end

      def get_type
        type, _ = slug.split('/', 2)
        type
      end
    end
  end
end
