module Docs
  class Cpp
    class FixUrlsFilter < Filter
      def call
        html.gsub! File.join(Cpp.base_url, Cpp.root_path), Cpp.base_url[0..-2]
        html.gsub! %r{#{Cpp.base_url}([^"']+?)\.html}, "#{Cpp.base_url}\\1"
        html
      end
    end
  end
end
