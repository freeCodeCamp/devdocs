module Docs
  class ScikitLearn
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'scikit-learn'

          css('.row-fluid').each do |node|
            html = '<dl>'
            node.css('.span4').each do |n|
              html += "<dt>#{n.first_element_child.inner_html}</dt>"
              html += "<dd>#{n.last_element_child.inner_html}</dd>"
            end
            html += '</dl>'
            node.replace(html)
          end
        end

        doc
      end
    end
  end
end

