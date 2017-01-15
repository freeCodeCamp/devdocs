module Docs
  class Bootstrap < UrlScraper
    self.type = 'bootstrap'
    self.links = {
      home: 'https://getbootstrap.com/',
      code: 'https://github.com/twbs/bootstrap'
    }

    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2017 Twitter, Inc.<br>
      &copy; 2011&ndash;2017 The Bootstrap Authors<br>
      Code licensed under the MIT License.<br>
      Documentation licensed under the Creative Commons Attribution License v3.0.
    HTML

    version '4' do
      self.release = 'alpha.6'
      self.base_url = 'https://v4-alpha.getbootstrap.com/'
      self.root_path = 'getting-started/introduction'

      html_filters.push 'bootstrap/entries_v4', 'bootstrap/clean_html_v4'

      options[:only_patterns] = [/\Agetting-started\//, /\Alayout\//, /\Acontent\//, /\Acomponents\//, /\Autilities\//]
    end

    version '3' do
      self.release = '3.3.7'
      self.base_url = 'https://getbootstrap.com/'
      self.root_path = 'getting-started'

      html_filters.push 'bootstrap/entries_v3', 'bootstrap/clean_html_v3'

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
