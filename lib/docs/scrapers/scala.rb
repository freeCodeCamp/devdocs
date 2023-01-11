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

    # For Scala 3, there is no official download link for the documentation
    # (see https://contributors.scala-lang.org/t/5537).
    #
    # We currently need to build the docs ourselves. To do so:
    # 1. Make sure that Scala 3 and sbt are installed
    #    (https://www.scala-lang.org/download/scala3.html)
    # 2. Clone the Scala 3 (Dotty) repository (https://github.com/lampepfl/dotty)
    # 3. From the Dotty folder, run this command in the terminal:
    #    $ sbt scaladoc/generateScalaDocumentation
    # 4. Extract scaladoc/output/scala3/api/ into docs/scala~3.1
    version '3.2' do
      self.release = '3.2.0'
      self.base_url = 'https://scala-lang.org/api/3.2.0/'
      self.root_path = 'index.html'

      options[:skip_patterns] = [
        # Ignore class names with include “#”, which cause issues with the scraper
        /%23/,

        # Ignore local links to the Java documentation created by a Scaladoc bug
        /java\/lang/,
      ]

      html_filters.push 'scala/entries_v3', 'scala/clean_html_v3'
    end

    version '3.1' do
      self.release = '3.1.1'
      self.base_url = 'https://scala-lang.org/api/3.1.1/'
      self.root_path = 'index.html'

      options[:skip_patterns] = [
        # Ignore class names with include “#”, which cause issues with the scraper
        /%23/,

        # Ignore local links to the Java documentation created by a Scaladoc bug
        /java\/lang/,
      ]

      html_filters.push 'scala/entries_v3', 'scala/clean_html_v3'
    end

    # https://downloads.lightbend.com/scala/2.13.0/scala-docs-2.13.0.zip
    # Extract api/scala-library into docs/scala~2.13_library
    version '2.13 Library' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    # https://downloads.lightbend.com/scala/2.13.0/scala-docs-2.13.0.zip
    # Extract api/scala-reflect into docs/scala~2.13_reflection
    version '2.13 Reflection' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/scala-reflect/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    # https://downloads.lightbend.com/scala/2.12.9/scala-docs-2.12.9.zip
    # Extract api/scala-library into docs/scala~2.12_library
    version '2.12 Library' do
      self.release = '2.12.9'
      self.base_url = 'https://www.scala-lang.org/api/2.12.9/'
      self.root_path = 'index.html'
      options[:container] = '#content-container'

      html_filters.push 'scala/entries_v2', 'scala/clean_html_v2'
    end

    # https://downloads.lightbend.com/scala/2.12.9/scala-docs-2.12.9.zip
    # Extract api/scala-reflect into docs/scala~2.12_reflection
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
  end
end
