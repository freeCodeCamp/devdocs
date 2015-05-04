module Docs
  class Drupal
    class NormalizePathsFilter < Docs::NormalizePathsFilter

      def store_path
        p = Drupal::fixUri(@path)
        File.extname(p) != '.html' ? "#{p}.html" : p
      end
    end
  end
end