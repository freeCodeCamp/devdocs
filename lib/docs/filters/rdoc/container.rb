module Docs
  class Rdoc
    class ContainerFilter < Filter
      def call
        return doc if context[:skip_rdoc_filters?].try(:call, self)

        if root_page?
          at_css 'main'
        else
          container = at_css 'main'

          # Add <dl> mentioning parent class and included modules
          meta = Nokogiri::XML::Node.new 'dl', doc
          meta['class'] = 'meta'

          if parent = at_css('#parent-class-section')
            meta << %(<dt>Parent:</dt><dd class="meta-parent">#{parent.at_css('.link').inner_html.strip}</dd>)
          end

          if includes = at_css('#includes-section')
            meta << %(<dt>Included modules:</dt><dd class="meta-includes">#{includes.css('a').map(&:to_html).join(', ')}</dd>)
          end

          if parent || includes
            container.at_css('h1').after(meta)
          end

          container
        end
      end
    end
  end
end
