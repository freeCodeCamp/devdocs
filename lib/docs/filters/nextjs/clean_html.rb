module Docs
    class Nextjs
        class CleanHtmlFilter < Filter
            def call
                css('.zola-anchor').remove
                doc.prepend_child("<h1>NextJS2</h1>") if root_page?
                css('div:contains("NEWS:")').remove
                css('h2:contains("sponsors"), #sponsor-table').remove
                css('div.sticky').remove #remove the floating menu
                css('footer').remove
                css('div.feedback_inlineTriggerWrapper__o7yUx').remove
                doc
            end
        end
    end
end
