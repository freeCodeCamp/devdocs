module Docs
  class Fish
    class CleanHtmlSphinxFilter < Filter
      def call
        @doc = at_css('.body > section') or at_css('.body')
        css('pre[data-language="fish"]').each do |node|
          node['data-language'] = 'shell'
        end
        doc
      end
    end
  end
end
