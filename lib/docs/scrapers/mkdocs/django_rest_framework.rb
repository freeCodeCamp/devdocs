module Docs
  class DjangoRestFramework < Mkdocs
    self.name = 'Django REST Framework'
    self.release = '3.9.3'
    self.slug = 'django_rest_framework'
    self.base_url = 'https://www.django-rest-framework.org/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.django-rest-framework.org/',
      code: 'https://github.com/encode/django-rest-framework'
    }

    html_filters.push 'django_rest_framework/clean_html', 'django_rest_framework/entries'

    options[:skip_patterns] = [
      /\Atopics\//,
      /\Acommunity\//,
    ]

    options[:attribution] = <<-HTML
      Copyright &copy; 2011&ndash;present Encode OSS Ltd.<br>
      Licensed under the BSD License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('encode', 'django-rest-framework', opts)
    end
  end
end
