module Docs
  class Django < FileScraper
    self.name = 'Django'
    self.type = 'sphinx'
    self.release = '1.8.6'
    self.dir = '/Users/Thibaut/DevDocs/Docs/Django'
    self.base_url = 'https://docs.djangoproject.com/en/1.8/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.djangoproject.com/',
      code: 'https://github.com/django/django'
    }

    html_filters.push 'django/entries', 'django/clean_html'
    text_filters.push 'django/fix_urls'

    options[:container] = '#bd'

    options[:skip] = %w(
      contents.html
      genindex.html
      py-modindex.html
      glossary.html
      search.html
      intro/whatsnext.html)

    options[:skip_patterns] = [
      /\Afaq\//,
      /\Ainternals\//,
      /\Amisc\//,
      /\Areleases\//,
      /\A_/,
      /flattened\-index\.html/]

    options[:attribution] = <<-HTML
      &copy; Django Software Foundation and individual contributors<br>
      Licensed under the BSD License.
    HTML
  end
end
