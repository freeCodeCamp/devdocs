module Docs
  class Bootstrap
    class CleanHtmlV5Filter < Filter
      def call

        @doc = at_css('main')
        at_css('.bd-content').prepend_child(at_css('h1').remove)
        @doc = at_css('.bd-content')

        # Toc
        css('.bd-toc').remove

        # 'View on Github' button
        css('.btn').remove

        at_css('h1').content = 'Bootstrap' if root_page?

        css('.highlight').each do |node|
          code = node.at_css('code')
          node['data-language'] = code['data-lang']
          node.content = code.content
          node.name = 'pre'
        end

        css('.bd-example').each do |node|
          node.remove
        end

        doc

      end
    end
  end
end
