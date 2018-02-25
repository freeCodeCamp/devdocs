module Docs
  class Postgresql < UrlScraper
    include FixInternalUrlsBehavior

    self.name = 'PostgreSQL'
    self.type = 'postgres'
    self.root_path = 'reference.html'
    self.initial_paths = %w(sql.html admin.html internals.html appendixes.html tutorial.html)
    self.links = {
      home: 'https://www.postgresql.org/',
      code: 'https://git.postgresql.org/gitweb/?p=postgresql.git'
    }

    html_filters.insert_before 'normalize_urls', 'postgresql/extract_metadata'
    html_filters.push 'postgresql/clean_html', 'postgresql/entries', 'title'

    options[:title] = false
    options[:root_title] = 'PostgreSQL'
    options[:follow_links] = ->(filter) { filter.initial_page? }

    options[:skip] = %w(
      index.html
      ddl-others.html
      functions-event-triggers.html
      functions-trigger.html
      textsearch-migration.html
      supported-platforms.html
      error-message-reporting.html
      error-style-guide.html
      plhandler.html
      sourcerepo.html
      git.html
      bug-reporting.html
      client-interfaces.html)

    options[:skip_patterns] = [
      /\Ainstall/,
      /\Aregress/,
      /\Aprotocol/,
      /\Asource/,
      /\Anls/,
      /\Afdw/,
      /\Atablesample/,
      /\Acustom-scan/,
      /\Abki/,
      /\Arelease/,
      /\Acontrib-prog/,
      /\Aexternal/,
      /\Adocguide/,
      /\Afeatures/,
      /\Aunsupported-features/ ]

    options[:attribution] = <<-HTML
      &copy; 1996&ndash;2018 The PostgreSQL Global Development Group<br>
      Licensed under the PostgreSQL License.
    HTML

    version '10' do
      self.release = '10.2'
      self.base_url = 'https://www.postgresql.org/docs/10/static/'
    end

    version '9.6' do
      self.release = '9.6.6'
      self.base_url = 'https://www.postgresql.org/docs/9.6/static/'

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end

    version '9.5' do
      self.release = '9.5.10'
      self.base_url = 'https://www.postgresql.org/docs/9.5/static/'

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end

    version '9.4' do
      self.release = '9.4.15'
      self.base_url = 'https://www.postgresql.org/docs/9.4/static/'

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end
  end
end
