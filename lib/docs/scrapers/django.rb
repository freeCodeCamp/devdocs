module Docs
  class Django < FileScraper
    self.name = 'Django'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.djangoproject.com/',
      code: 'https://github.com/django/django'
    }

    html_filters.push 'django/entries', 'sphinx/clean_html', 'django/clean_html'
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

    version '2.1' do
      self.release = '2.1.0'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django21'
      self.base_url = 'https://docs.djangoproject.com/en/2.1/'
    end

    version '2.0' do
      self.release = '2.0.7'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django20'
      self.base_url = 'https://docs.djangoproject.com/en/2.0/'
    end

    version '1.11' do
      self.release = '1.11.9'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django111'
      self.base_url = 'https://docs.djangoproject.com/en/1.11/'
    end

    version '1.10' do
      self.release = '1.10.8'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django110'
      self.base_url = 'https://docs.djangoproject.com/en/1.10/'
    end

    version '1.9' do
      self.release = '1.9.13'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django19'
      self.base_url = 'https://docs.djangoproject.com/en/1.9/'
    end

    version '1.8' do
      self.release = '1.8.18'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Django18'
      self.base_url = 'https://docs.djangoproject.com/en/1.8/'
    end
  end
end
