module Docs
  class Django
    class FixUrlsFilter < Filter
      def call
        html.gsub! %r{#{Regexp.escape(context[:base_url].to_s)}([^"']+?)\.html}, "#{context[:base_url]}\\1/"
        html
      end
    end
  end
end
