module Docs
  class Graphviz
    class CleanHtmlFilter < Filter
      def call
        css('[tabindex]').remove_attribute('tabindex')

        content = at_css('.td-content')
        @doc = content if content

        css('a:contains("Search the Graphviz codebase")').remove
        css('.td-page-meta__lastmod').remove

        css('pre:has(code)').each do |node|
          pre = Nokogiri::XML::Node.new('pre', @doc)
          code = node.at_css('code')

          if code['data-lang']
            # Syntax highlighting is embedded into this HTML markup.
            pre['data-language'] = code['data-lang']
          else
            # Plain example source-code without highlighting.
            # Let's guess the language.
            sourcecode = code.content.strip
            if sourcecode =~ /^\$/
              # Starts with '$'? Probably a shell session.
              pre['data-language'] = 'shell-session'
            elsif sourcecode =~ /^cmd /
              # Command line example. No highlighting needed.
              pre['data-language'] = ''
            elsif sourcecode =~ /^void /
              # C language.
              pre['data-language'] = 'c'
            else
              # Nothing else? Let's guess DOT.
              pre['data-language'] = 'dot'
            end
          end
          pre.content = code.content

          node.replace(pre)
        end

        doc
      end
    end
  end
end
