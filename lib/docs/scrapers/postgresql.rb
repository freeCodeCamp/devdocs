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
      &copy; 1996&ndash;2023 The PostgreSQL Global Development Group<br>
      Licensed under the PostgreSQL License.
    HTML

    version 'Latest' do
      self.release = '16.0'
      self.base_url = "https://www.postgresql.org/docs/latest/"
    end
    
    version '16' do
      self.release = '16.0'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end
    
    version '15' do
      self.release = '15.4'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '14' do
      self.release = '14.9'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '13' do
      self.release = '13.12'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '12' do
      self.release = '12.16'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '11' do
      self.release = '11.21'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '10' do
      self.release = '10.23 (EOL)'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"
    end

    version '9.6' do
      self.release = '9.6.24 (EOL)'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end

    version '9.5' do
      self.release = '9.5.25 (EOL)'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end

    version '9.4' do
      self.release = '9.4.26 (EOL)'
      self.base_url = "https://www.postgresql.org/docs/#{version}/"

      html_filters.insert_before 'postgresql/extract_metadata', 'postgresql/normalize_class_names'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.postgresql.org/docs/current/index.html', opts)
      label = doc.at_css('#pgContentWrap h1.title').content
      label.scan(/([0-9.]+)/)[0][0]
    end
  end
end
