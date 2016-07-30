module Docs
  class Bootstrap < UrlScraper
    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2016 Twitter, Inc.<br>
      Code licensed under the MIT License.<br>
      Documentation licensed under the Creative Commons Attribution License v3.0.
    HTML

    version '3' do
      self.type = 'bsv3'
      self.release = '3.3.7'
      self.base_url = 'https://getbootstrap.com/'
      self.root_path = 'getting-started'
      self.links = {
        home: 'https://getbootstrap.com/',
        code: 'https://github.com/twbs/bootstrap'
      }

      html_filters.push 'bootstrap/entries_v3', 'bootstrap/clean_html_v3'

      options[:trailing_slash] = false
      options[:only] = %w(getting-started css components javascript)
    end

    private

    def handle_response(response)
      response.effective_url.scheme = 'https'
      response.effective_url.path = response.effective_url.path.remove(/\/\z/)
      super
    end
  end
end
