module Docs
  class Scala < FileScraper
    self.name = 'Scala'
    self.type = 'scala'
    self.links = {
      home: 'http://www.scala-lang.org/',
      code: 'https://github.com/scala/scala'
    }

    options[:container] = '#content-container'
    options[:attribution] = <<-HTML
        &copy; 2002-2019 EPFL, with contributions from Lightbend.<br>
        Licensed under the Apache License, Version 2.0.
    HTML

    # https://downloads.lightbend.com/scala/2.13.0/scala-docs-2.13.0.zip
    # Extract api/scala-library into docs/scala~2.13_library
    version '2.13 Library' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/'
      self.root_path = 'index.html'

      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    # https://downloads.lightbend.com/scala/2.13.0/scala-docs-2.13.0.zip
    # Extract api/scala-reflect into docs/scala~2.13_reflection
    version '2.13 Reflection' do
      self.release = '2.13.0'
      self.base_url = 'https://www.scala-lang.org/api/2.13.0/scala-reflect/'
      self.root_path = 'index.html'

      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    # https://downloads.lightbend.com/scala/2.12.9/scala-docs-2.12.9.zip
    # Extract api/scala-library into docs/scala~2.12_library
    version '2.12 Library' do
      self.release = '2.12.9'
      self.base_url = 'https://www.scala-lang.org/api/2.12.9/'
      self.root_path = 'index.html'

      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    # https://downloads.lightbend.com/scala/2.12.9/scala-docs-2.12.9.zip
    # Extract api/scala-reflect into docs/scala~2.12_reflection
    version '2.12 Reflection' do
      self.release = '2.12.9'
      self.base_url = 'https://www.scala-lang.org/api/2.12.9/scala-reflect/'
      self.root_path = 'index.html'

      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://www.scala-lang.org/api/current/', opts)
      doc.at_css('#doc-version').content
    end
  end
end
