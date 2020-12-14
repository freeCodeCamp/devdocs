module Docs
  class ScikitLearn
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('.row').each do |node|
            html = '<dl>'
            node.css('.card-body').each do |n|
              html += '<dt>'
              html += "<a href='#{n.at_css('a')['href']}'>#{n.at_css('h4').content}</a>"
              html += '</dt>'
              html += "<dd>#{n.css('.card-text').to_html}</dd>"
            end
            html += '</dl>'
            node.replace(html)
          end
        end

        css('.sphx-glr-signature').remove

        doc
      end
    end
  end
end
