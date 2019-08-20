module Docs
  class Mkdocs < UrlScraper
    self.abstract = true
    self.type = 'mkdocs'

    html_filters.push 'mkdocs/clean_html'

    private

    def handle_response(response)
      # Some scrapped urls don't have ending slash
      # which leads to page duplication
      if !response.url.path.ends_with?('/') && !response.url.path.ends_with?('index.html')
        response.url.path << '/'
      end
      super
    end
  end
end
