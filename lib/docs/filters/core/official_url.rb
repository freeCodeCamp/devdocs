module Docs
  class OfficialUrlFilter < Filter
    def call
      official_url_html << html if base_url
    end

    def official_url_html
      <<-HTML.strip_heredoc
      <div class="_official">
        Official Documentation: <a href="#{base_url}" class="_official-link">#{base_url}</a>
      </div>
      HTML
    end
  end
end
