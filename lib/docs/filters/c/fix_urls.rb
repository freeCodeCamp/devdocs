module Docs
  class C
    class FixUrlsFilter < Filter
      def call
        html.gsub! File.join(C.base_url, C.root_path), C.base_url[0..-2]
        html.gsub! %r{#{C.base_url}([^"']+?)\.html}, "#{C.base_url}\\1"
        html
      end
    end
  end
end
