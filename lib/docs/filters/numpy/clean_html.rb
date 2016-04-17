module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#spc-section-body')

        css('.headerlink').remove  # remove permalinks

        # Add class for correct syntax highlighting
        css('pre').each do |pre|
          pre['class'] = 'python'
        end

        doc
      end
    end
  end
end
