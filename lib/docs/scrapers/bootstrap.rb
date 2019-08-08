module Docs
  class Bootstrap < UrlScraper
    self.type = 'bootstrap'
    self.links = {
      home: 'https://getbootstrap.com/',
      code: 'https://github.com/twbs/bootstrap'
    }

    options[:trailing_slash] = true

    # https://github.com/twbs/bootstrap/blob/master/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2011&ndash;2019 Twitter, Inc.<br>
      &copy; 2011&ndash;2019 The Bootstrap Authors<br>
      Code licensed under the MIT License.<br>
      Documentation licensed under the Creative Commons Attribution License v3.0.
    HTML

    version '4' do
      self.release = '4.3.1'
      self.base_url = 'https://getbootstrap.com/docs/4.3/'
      self.root_path = 'getting-started/introduction/'

      html_filters.push 'bootstrap/entries_v4', 'bootstrap/clean_html_v4'

      options[:only_patterns] = [/\Agetting-started\//, /\Alayout\//, /\Acontent\//, /\Acomponents\//, /\Autilities\//, /\Amigration\//]
    end

    version '3' do
      self.release = '3.3.7'
      self.base_url = 'https://getbootstrap.com/docs/3.3/'
      self.root_path = 'getting-started/'

      html_filters.push 'bootstrap/entries_v3', 'bootstrap/clean_html_v3'

      options[:only] = %w(getting-started/ css/ components/ javascript/)
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://getbootstrap.com/', opts)
      doc.at_css('#bd-versions').content.strip[1..-1]
    end
  end
end
