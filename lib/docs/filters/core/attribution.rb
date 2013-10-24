module Docs
  class AttributionFilter < Filter
    def call
      html << attribution_info if attribution
      html
    end

    def attribution
      context[:attribution]
    end

    def attribution_url
      current_url.to_s
    end

    def attribution_info
      <<-HTML.strip_heredoc
      <div class="_attribution">
        <p class="_attribution-p">
          #{attribution.delete "\n"}<br>
          <a href="#{attribution_url}" class="_attribution-link">#{attribution_url}</a>
        </p>
      </div>
      HTML
    end
  end
end
