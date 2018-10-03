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
  end
end
