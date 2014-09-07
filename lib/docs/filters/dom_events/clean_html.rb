module Docs
  class DomEvents
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        # Remove parapraph mentioning non-standard events
        at_css('#Standard_events').previous_element.remove

        # Remove everything after "Standard events"
        css('.standard-table ~ *').remove

        # Remove events we don't want
        css('tr').each do |tr|
          if td = tr.at_css('td:nth-child(3)')
            tr.remove if td.content =~ /SVG|Battery|Gamepad|Sensor/i
          end
        end
      end

      def other
        css('#General_info + dl').each do |node|
          node['class'] = 'eventinfo'
        end
      end
    end
  end
end
