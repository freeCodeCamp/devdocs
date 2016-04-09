module Docs
  class Underscore
    class CleanHtmlFilter < Filter
      def call
        # Remove Links, Changelog
        css('#links ~ *', '#links').remove

        css('pre').each do |node|
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
