module Docs
  class Postgresql < FileScraper
    self.name = 'PostgreSQL'
    self.type = 'postgres'
    self.version = 'up to 9.3.2'
    self.dir = '/Users/Thibaut/DevDocs/Docs/PostgreSQL'
    self.base_url = 'http://www.postgresql.org/docs/9.3/static/'
    self.root_path = 'reference.html'
    self.initial_paths = %w(sql.html runtime-config.html charset.html)

    html_filters.insert_before 'normalize_urls', 'postgresql/clean_nav'
    html_filters.push 'postgresql/clean_html', 'postgresql/entries', 'title'

    options[:title] = false
    options[:root_title] = 'PostgreSQL'
    options[:follow_links] = ->(filter) { filter.initial_page? }

    options[:only] = %w(
      arrays.html
      rowtypes.html
      rangetypes.html
      mvcc-intro.html
      transaction-iso.html
      explicit-locking.html
      applevel-consistency.html
      locking-indexes.html
      config-setting.html
      locale.html
      collation.html
      multibyte.html)

    options[:only_patterns] = [
      /\Asql\-/,
      /\Aapp\-/,
      /\Addl\-/,
      /\Adml\-/,
      /\Aqueries\-/,
      /\Adatatype\-/,
      /\Afunctions\-/,
      /\Aindexes\-/,
      /\Aruntime\-config\-/]

    options[:skip] = %w(
      ddl-others.html
      runtime-config-custom.html
      runtime-config-short.html
      functions-event-triggers.html
      functions-trigger.html)

    options[:attribution] = <<-HTML
      &copy; 1996&ndash;2013 The PostgreSQL Global Development Group<br>
      Licensed under the PostgreSQL License.
    HTML
  end
end
