# frozen_string_literal: true

module Docs
  class AttributionFilter < Filter
    def call
      html << attribution_html if attribution
      html
    end

    def attribution
      if context[:attribution].is_a?(String)
        context[:attribution]
      else
        context[:attribution].call(self)
      end
    end

    def attribution_html
      <<-HTML.strip_heredoc
      <div class="_attribution">
        <p class="_attribution-p">
          #{attribution.strip_heredoc.delete "\n"}<br>
          #{attribution_link}
        </p>
      </div>
      HTML
    end

    def attribution_link
      unless base_url.host == 'localhost'
        %(<a href="#{current_url}" class="_attribution-link">#{current_url}</a>)
      end
    end
  end
end
