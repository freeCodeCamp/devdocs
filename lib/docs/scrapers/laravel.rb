module Docs
  class Laravel < UrlScraper
    self.type = 'laravel'
    self.base_url = 'https://laravel.com'
    self.links = {
      home: 'https://laravel.com/',
      code: 'https://github.com/laravel/laravel'
    }

    html_filters.push 'laravel/entries', 'laravel/clean_html'

    options[:container] = ->(filter) {
      filter.subpath.start_with?('/api') ? '#content' : '.docs-wrapper'
    }

    options[:skip_patterns] = [
      %r{\A/api/\d\.\d/\.html},
      %r{\A/api/\d\.\d/panel\.html},
      %r{\A/api/\d\.\d/namespaces\.html},
      %r{\A/api/\d\.\d/interfaces\.html},
      %r{\A/api/\d\.\d/traits\.html},
      %r{\A/api/\d\.\d/doc-index\.html},
      %r{\A/api/\d\.\d/Illuminate\.html},
      %r{\A/api/\d\.\d/search\.html} ]

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.<br>
      Laravel is a trademark of Taylor Otwell.
    HTML

    version '6.0' do
      self.release = '6.0.1'
      self.root_path = '/api/6.x/index.html'
      self.initial_paths = %w(/docs/6.0/installation /api/6.x/classes.html)

      options[:only_patterns] = [%r{\A/api/6\.x/}, %r{\A/docs/6\.0/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/6.0/"
        url
      end
    end

    version '5.8' do
      self.release = '5.8.35'
      self.root_path = '/api/5.8/index.html'
      self.initial_paths = %w(/docs/5.8/installation /api/5.8/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.8/}, %r{\A/docs/5\.8/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.8/"
        url
      end
    end

    version '5.7' do
      self.release = '5.7.28'
      self.root_path = '/api/5.7/index.html'
      self.initial_paths = %w(/docs/5.7/installation /api/5.7/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.7/}, %r{\A/docs/5\.7/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.7/"
        url
      end
    end

    version '5.6' do
      self.release = '5.6.39'
      self.root_path = '/api/5.6/index.html'
      self.initial_paths = %w(/docs/5.6/installation /api/5.6/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.6/}, %r{\A/docs/5\.6/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.6/"
        url
      end
    end

    version '5.5' do
      self.release = '5.5.48'
      self.root_path = '/api/5.5/index.html'
      self.initial_paths = %w(/docs/5.5/installation /api/5.5/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.5/}, %r{\A/docs/5\.5/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.5/"
        url
      end
    end

    version '5.4' do
      self.release = '5.4.36'
      self.root_path = '/api/5.4/index.html'
      self.initial_paths = %w(/docs/5.4/installation /api/5.4/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.4/}, %r{\A/docs/5\.4/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.4/"
        url
      end
    end

    version '5.3' do
      self.release = '5.3.31'
      self.root_path = '/api/5.3/index.html'
      self.initial_paths = %w(/docs/5.3/installation /api/5.3/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.3/}, %r{\A/docs/5\.3/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.3/"
        url
      end
    end

    version '5.2' do
      self.release = '5.2.45'
      self.root_path = '/api/5.2/index.html'
      self.initial_paths = %w(/docs/5.2/installation /api/5.2/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.2/}, %r{\A/docs/5\.2/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.2/"
        url
      end
    end

    version '5.1' do
      self.release = '5.1.46'
      self.root_path = '/api/5.1/index.html'
      self.initial_paths = %w(/docs/5.1/installation /api/5.1/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.1/}, %r{\A/docs/5\.1/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.1/"
        url
      end
    end

    version '5.0' do
      self.release = '5.0.35'
      self.root_path = '/api/5.0/index.html'
      self.initial_paths = %w(/docs/5.0/installation /api/5.0/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.0/}, %r{\A/docs/5\.0/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.0/"
        url
      end
    end

    version '4.2' do
      self.release = '4.2.22'
      self.root_path = '/api/4.2/index.html'
      self.initial_paths = %w(/docs/4.2/installation /api/4.2/classes.html)

      options[:only_patterns] = [%r{\A/api/4\.2/}, %r{\A/docs/4\.2/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/4.2/"
        url
      end
    end

    def get_latest_version(opts)
      get_latest_github_release('laravel', 'laravel', opts)
    end
  end
end
