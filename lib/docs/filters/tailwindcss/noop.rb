module Docs
  class Tailwindcss
    class NoopFilter < Filter
      def call
        return html
      end
    end
  end
end
