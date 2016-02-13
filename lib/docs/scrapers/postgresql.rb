module Docs
  class Postgresql < UrlScraper
    include FixInternalUrlsBehavior

    self.name = 'PostgreSQL'
    self.type = 'postgres'
    self.root_path = 'reference.html'
    self.initial_paths = %w(sql.html admin.html internals.html)

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
      plhandler.html)

    options[:skip_patterns] = [
      /\Atutorial/,
      /\Ainstall/,
      /\Aregress/,
      /\Aprotocol/,
      /\Asource/,
      /\Anls/,
      /\Afdw/,
      /\Atablesample/,
      /\Acustom-scan/,
      /\Abki/ ]

    options[:attribution] = <<-HTML
      &copy; 1996&ndash;2016 The PostgreSQL Global Development Group<br>
      Licensed under the PostgreSQL License.
    HTML

    version '9.5' do
      self.release = '9.5'
      self.base_url = 'http://www.postgresql.org/docs/9.5/static/'
    end

    version '9.4' do
      self.release = '9.4'
      self.base_url = 'http://www.postgresql.org/docs/9.4/static/'
    end
  end
end
