module Docs
  class Scala < FileScraper
    self.name = 'Scala'
    self.type = 'scala'
    self.links = {
      home: 'https://www.scala-lang.org/',
      code: 'https://github.com/scala/scala'
    }

    options[:attribution] = <<-HTML
        &copy; 2002-2022 EPFL, with contributions from Lightbend.<br>
        Licensed under the Apache License, Version 2.0.
    HTML

    version '3' do
      self.release = '3.8.4'
      self.base_url = "https://scala-lang.org/api/#{release}/"
      self.root_path = 'index.html'

      # The published artifact links to the nightly documentation instead of
      # using relative links.
      doc_root = base_url.to_s
      options[:fix_urls_before_parse] = ->(url) do
        url.sub('https://nightly.scala-lang.org/api/', doc_root)
      end

      options[:skip_patterns] = [
        # Ignore class names with include “#”, which cause issues with the scraper
        /%23/,

        # Ignore local links to the Java documentation created by a Scaladoc bug
        /java\/lang/,
      ]

      html_filters.push 'scala/entries_v3', 'scala/clean_html_v3'
    end

    version '2.13 Library' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    version '2.13 Reflection' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/scala-reflect/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    version '2.12 Library' do
      self.release = '2.12.9'
      self.base_url = 'https://www.scala-lang.org/api/2.12.9/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    version '2.12 Reflection' do
      self.release = '2.12.9'
      self.base_url = 'https://www.scala-lang.org/api/2.12.9/scala-reflect/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.scala-lang.org/api/3.x/', opts)
      doc.at_css('.projectVersion').content
    end

    private

    def download_source
      # Since 3.8.0, the Scala 3 standard library documentation is published to
      # Maven Central as the javadoc artifact of org.scala-lang:scala-library, e.g.
      # https://repo1.maven.org/maven2/org/scala-lang/scala-library/3.8.4/scala-library-3.8.4-javadoc.jar
      if self.class.version == '3'
        return download_and_extract("https://repo1.maven.org/maven2/org/scala-lang/scala-library/#{self.class.release}/scala-library-#{self.class.release}-javadoc.jar")
      end

      # Scala 2 ships the documentation of both modules in a single archive, e.g.
      # https://downloads.lightbend.com/scala/2.13.0/scala-docs-2.13.0.zip
      subdirectory = case self.class.version
                     when /Library\z/ then 'scala-library'
                     when /Reflection\z/ then 'scala-reflect'
                     end

      download_and_extract("https://downloads.lightbend.com/scala/#{self.class.release}/scala-docs-#{self.class.release}.zip",
                           "scala-#{self.class.release}/api/#{subdirectory}")
    end
  end
end
