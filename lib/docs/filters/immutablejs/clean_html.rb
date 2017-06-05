module Docs
  class Immutablejs
    class CleanHtmlFilter < Filter
      def call
        # Skip the container "div"
        @doc = at_css('div')

        # Remove data-reactid attributes for cleaner html
        css('*[data-reactid]').each do |reactEl|
          reactEl.delete 'data-reactid'
        end

        # Add id to member label, so we can navigate among them
        css('h3.memberLabel').each do |memberLabel|
          memberLabel['id'] = memberLabel.content.strip.chomp('()')
        end


        css('a').each do |link|
          # Remove "/" from the start
          link['href'] = link['href'].gsub(/^(#)?\//, '')

          # We need to convert links - from Iterable/butLast to Iterable#butLast
          link['href'] = link['href'].split('/').join('#')
        end

        # Replace code blocks tag code with pre, and add stylings.
        css('code.codeBlock').each do |codeBlock|
          codeBlock.name = 'pre'
          codeBlock['data-language'] = 'javascript'
          codeBlock['class'] = 'language-javascript'
        end

        doc
      end
    end
  end
end
