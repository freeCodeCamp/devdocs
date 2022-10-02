module Docs
  class Svelte
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main > .content')
        at_css('h1').content = 'Svelte'
        doc
      end
    end
  end
end
