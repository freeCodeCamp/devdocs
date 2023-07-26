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
      &copy; 2011&ndash;2023 The Bootstrap Authors<br>
      Code licensed under the MIT License.<br>
      Documentation licensed under the Creative Commons Attribution License v3.0.
    HTML

    version '5' do
      self.release = '5.3'
      self.base_url = "https://getbootstrap.com/docs/#{self.release}/"
      self.root_path = 'getting-started/introduction/'

      html_filters.push 'bootstrap/entries_v5', 'bootstrap/clean_html_v5'

      options[:skip_patterns] = [
        /\Aabout\//
      ]

      options[:replace_paths] = {
        'components/breadcrumb//' => '/components/breadcrumb/'
      }

    end

    version '4' do
      self.release = '4.5'
      self.base_url = "https://getbootstrap.com/docs/#{self.release}/"
      self.root_path = 'getting-started/introduction/'

      html_filters.push 'bootstrap/entries_v4', 'bootstrap/clean_html_v4'

      options[:only_patterns] = [
        /\Agetting-started\//, /\Alayout\//, /\Acontent\//,
        /\Acomponents\//, /\Autilities\/.+/, /\Amigration\//
      ]

    end

    version '3' do
      self.release = '3.4.1'
      self.base_url = 'https://getbootstrap.com/docs/3.4/'
      self.root_path = 'getting-started/'

      html_filters.push 'bootstrap/entries_v3', 'bootstrap/clean_html_v3'

      options[:only] = %w(getting-started/ css/ components/ javascript/)
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://getbootstrap.com/docs/versions/', opts)
      doc.at_css('span:contains("Latest")').parent.content.split(' ').first
    end

  end
end
