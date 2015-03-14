module Docs
  class HomeUrlFilter < Filter
    def call
      html.prepend(home_url_html) if home_url
      html
    end

    def home_url_html
      <<-HTML.strip_heredoc
      <div class="_official">
        Official Documentation: <a href="#{home_url}" class="_official-link">#{home_url}</a>
      </div>
      HTML
    end
  end
end
