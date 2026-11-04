module Docs
  class Laravel < UrlScraper
    include MultipleBaseUrls

    self.type = 'laravel'
    self.links = {
      home: 'https://laravel.com/',
      code: 'https://github.com/laravel/laravel'
    }

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.current_url.origin.start_with?('https://api.laravel.com') ? '#content' : '#docsScreen'
    }

    options[:skip] = %w(
      namespaces.html
      interfaces.html
      traits.html
      doc-index.html
      Illuminate.html
      search.html
    )

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.<br>
      Laravel is a trademark of Taylor Otwell.
    HTML

    def initial_urls
      if self.class.version.to_i < 6
        return [
          "https://laravel.com/framework/docs/#{self.class.version}/installation",
        ]
      end

      return [
        "https://laravel.com/framework/docs/#{self.class.version}.x/installation",
        "https://api.laravel.com/docs/#{self.class.version}.x/classes.html"
      ]
    end

    version '13' do
      self.release = '13.38.0'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]

      # Prevent infinite replacement while rewriting from unversioned url to versioned
      options[:fix_urls] = ->(url) do
        url.sub(
          %r{\Ahttps://laravel\.com/framework/docs/(?!#{version}\.x/)},
          'https://laravel.com/framework/docs/13.x/'
        )
      end
    end

    version '12' do
      self.release = '12.70.1'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '11' do
      self.release = '11.51.0'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '10' do
      self.release = '10.48.26'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '9' do
      self.release = '9.52.16'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '8' do
      self.release = '8.83.27'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '7' do
      self.release = '7.30.6'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '6' do
      self.release = '6.20.44'
      self.base_url = "https://api.laravel.com/docs/#{version}.x/index.html"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}.x/",
        "https://api.laravel.com/docs/#{version}.x/",
      ]
    end

    version '5.8' do
      self.release = '5.8.38'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.7' do
      self.release = '5.7.7'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.6' do
      self.release = '5.6.33'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.5' do
      self.release = '5.5.28'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.4' do
      self.release = '5.4.30'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.3' do
      self.release = '5.3.30'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.2' do
      self.release = '5.2.31'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.1' do
      self.release = '5.1.33'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end

    version '5.0' do
      self.release = '5.0'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]
    end


    version '4.2' do
      self.release = '4.2.11'
      self.base_url = "https://laravel.com/framework/docs/#{version}/installation"
      self.base_urls = [
        "https://laravel.com/framework/docs/#{version}/",
      ]

      options[:fix_urls] = ->(url) do
        url.sub(
          %r{\Ahttps://laravel\.com/docs/4\.2/},
          'https://laravel.com/framework/docs/4.2/'
        )
      end
    end

    def get_latest_version(opts)
      get_latest_github_release('laravel', 'laravel', opts)
    end
  end
end
