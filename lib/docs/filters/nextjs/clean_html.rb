module Docs
    class Nextjs
        class CleanHtmlFilter < Filter
            def call
                @doc = at_css('.prose')

                css('.zola-anchor').remove
                doc.prepend_child("<h1>NextJS2</h1>") if root_page?
                css('div:contains("NEWS:")').remove
                css('h2:contains("sponsors"), #sponsor-table').remove
                css('div.sticky').remove #remove the floating menu
                css('div.-mt-4').remove #remove the navigation line
                css('footer').remove
                css('div.feedback_inlineTriggerWrapper__o7yUx').remove
                css('header').remove #remove links from the top of the page
                css('nav').remove

                css('h1, h2, h3, h4').each { |node| node.content = node.content }

                css('pre > code').each do |node|
                  node.parent['data-language'] = 'typescript'
                  node.parent.content = node.parent.content
                end
                css('div[class^="code-block_header"]').remove

                doc
            end
        end
    end
end
