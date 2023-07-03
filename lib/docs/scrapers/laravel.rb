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
      filter.subpath.start_with?('/api') ? '#content' : '#docsScreen'
    }

    options[:skip_patterns] = [
      %r{\A/api/[1-9]?\d\.[0-9x]/\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/panel\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/namespaces\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/interfaces\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/traits\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/doc-index\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/Illuminate\.html},
      %r{\A/api/[1-9]?\d\.[0-9x]/search\.html} ]

    options[:attribution] = <<-HTML
      &copy; Taylor Otwell<br>
      Licensed under the MIT License.<br>
      Laravel is a trademark of Taylor Otwell.
    HTML

    version '10' do
      self.release = '10.13.0'
      self.root_path = '/api/10.x/index.html'
      self.initial_paths = %w(/docs/10.x/installation /api/10.x/classes.html)

      options[:only_patterns] = [%r{\A/api/10\.x/}, %r{\A/docs/10\.x/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{10.x/+}, "10.x/"
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?![1-9]?\d)}, "#{Laravel.base_url}/docs/10.x/"
        url
      end
    end

    version '9' do
      self.release = '9.52.8'
      self.root_path = '/api/9.x/index.html'
      self.initial_paths = %w(/docs/9.x/installation /api/9.x/classes.html)

      options[:only_patterns] = [%r{\A/api/9\.x/}, %r{\A/docs/9\.x/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{9.x/+}, "9.x/"
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/9.x/"
        url
      end
    end

    version '8' do
      self.release = '8.83.27'
      self.root_path = '/api/8.x/index.html'
      self.initial_paths = %w(/docs/8.x/installation /api/8.x/classes.html)

      options[:only_patterns] = [%r{\A/api/8\.x/}, %r{\A/docs/8\.x/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{8.x/+}, "8.x/"
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/8.x/"
        url
      end
    end

    version '7' do
      self.release = '7.30.6'
      self.root_path = '/api/7.x/index.html'
      self.initial_paths = %w(/docs/7.x/installation /api/7.x/classes.html)

      options[:only_patterns] = [%r{\A/api/7\.x/}, %r{\A/docs/7\.x/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{7.x/+}, "7.x/"
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/7.x/"
        url
      end
    end

    version '6' do
      self.release = '6.20.44'
      self.root_path = '/api/6.x/index.html'
      self.initial_paths = %w(/docs/6.x/installation /api/6.x/classes.html)

      options[:only_patterns] = [%r{\A/api/6\.x/}, %r{\A/docs/6\.x/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{6.x/+}, "6.x/"
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/6.x/"
        url
      end
    end

    version '5.8' do
      self.release = '5.8.38'
      self.root_path = '/api/5.8/index.html'
      self.initial_paths = %w(/docs/5.8/installation /api/5.8/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.8/}, %r{\A/docs/5\.8/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.8/"
        url
      end
    end

    version '5.7' do
      self.release = '5.7.7'
      self.root_path = '/api/5.7/index.html'
      self.initial_paths = %w(/docs/5.7/installation /api/5.7/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.7/}, %r{\A/docs/5\.7/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.7/"
        url
      end
    end

    version '5.6' do
      self.release = '5.6.33'
      self.root_path = '/api/5.6/index.html'
      self.initial_paths = %w(/docs/5.6/installation /api/5.6/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.6/}, %r{\A/docs/5\.6/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.6/"
        url
      end
    end

    version '5.5' do
      self.release = '5.5.28'
      self.root_path = '/api/5.5/index.html'
      self.initial_paths = %w(/docs/5.5/installation /api/5.5/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.5/}, %r{\A/docs/5\.5/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.5/"
        url
      end
    end

    version '5.4' do
      self.release = '5.4.30'
      self.root_path = '/api/5.4/index.html'
      self.initial_paths = %w(/docs/5.4/installation /api/5.4/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.4/}, %r{\A/docs/5\.4/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.4/"
        url
      end
    end

    version '5.3' do
      self.release = '5.3.30'
      self.root_path = '/api/5.3/index.html'
      self.initial_paths = %w(/docs/5.3/installation /api/5.3/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.3/}, %r{\A/docs/5\.3/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.3/"
        url
      end
    end

    version '5.2' do
      self.release = '5.2.31'
      self.root_path = '/api/5.2/index.html'
      self.initial_paths = %w(/docs/5.2/installation /api/5.2/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.2/}, %r{\A/docs/5\.2/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.2/"
        url
      end
    end

    version '5.1' do
      self.release = '5.1.33'
      self.root_path = '/api/5.1/index.html'
      self.initial_paths = %w(/docs/5.1/installation /api/5.1/classes.html)

      options[:only_patterns] = [%r{\A/api/5\.1/}, %r{\A/docs/5\.1/}]

      options[:fix_urls] = ->(url) do
        url.sub! %r{#{Regexp.escape(Laravel.base_url)}/docs\/(?!\d)}, "#{Laravel.base_url}/docs/5.1/"
        url
      end
    end


    version '4.2' do
      self.release = '4.2.11'
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
