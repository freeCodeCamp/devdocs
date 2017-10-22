module Docs
  class Scala < FileScraper
    include FixInternalUrlsBehavior

    self.name = 'scala'
    self.type = 'scala'
    self.links = {
      home: 'http://www.scala-lang.org/',
      code: 'https://github.com/scala/scala'
    }

    version 'Library 2.12' do
      self.release = '2.12.3'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Scala212/api/scala-library' # https://downloads.lightbend.com/scala/2.12.3/scala-docs-2.12.3.zip
      self.base_url = 'http://www.scala-lang.org/api/2.12.3/'
      self.root_path = 'index.html'
      options[:attribution] = <<-HTML
        Scala programming documentation. Copyright (c) 2003-2017 <a
        href="http://www.epfl.ch" target="_blank">EPFL</a>, with contributions from <a
        href="http://www.lightbend.com" target="_blank">Lightbend</a>.
      HTML
      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    version 'Reflection 2.12' do
      self.release = '2.12.3'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Scala212/api/scala-reflect' # https://downloads.lightbend.com/scala/2.12.3/scala-docs-2.12.3.zip
      self.base_url = 'http://www.scala-lang.org/api/2.12.3/scala-reflect/'
      self.root_path = 'index.html'
      options[:attribution] = <<-HTML
        Scala programming documentation. Copyright (c) 2003-2017 <a
        href="http://www.epfl.ch" target="_blank">EPFL</a>, with contributions from <a
        href="http://www.lightbend.com" target="_blank">Lightbend</a>.
      HTML
      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    version 'Library 2.11' do
      self.release = '2.11.8'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Scala211/api/scala-library' # https://downloads.lightbend.com/scala/2.11.8/scala-docs-2.11.8.zip
      self.base_url = 'http://www.scala-lang.org/api/2.11.8/'
      self.root_path = 'package.html'
      options[:skip_patterns] = [/^index.html/, /index\/index-/]
      options[:attribution] = <<-HTML
        Scala programming documentation. Copyright (c) 2003-2016 <a
        href="http://www.epfl.ch" target="_blank">EPFL</a>, with contributions from <a
        href="http://www.lightbend.com" target="_blank">Lightbend</a>.
      HTML
      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    version 'Reflection 2.11' do
      self.release = '2.11.8'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Scala211/api/scala-reflect' # https://downloads.lightbend.com/scala/2.11.8/scala-docs-2.11.8.zip
      self.base_url = 'http://www.scala-lang.org/api/2.11.8/scala-reflect/'
      self.root_path = 'package.html'
      options[:skip_patterns] = [/^index.html/, /index\/index-/]
      options[:attribution] = <<-HTML
        Scala programming documentation. Copyright (c) 2003-2016 <a
        href="http://www.epfl.ch" target="_blank">EPFL</a>, with contributions from <a
        href="http://www.lightbend.com" target="_blank">Lightbend</a>.
      HTML
      html_filters.push 'scala/entries', 'scala/clean_html'
    end

    version '2.10' do
      self.release = '2.10.6'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Scala210' # https://downloads.lightbend.com/scala/2.10.6/scala-docs-2.10.6.zip
      self.base_url = 'http://www.scala-lang.org/api/2.10.6/'
      self.root_path = 'package.html'
      options[:skip_patterns] = [/^index.html/, /index\/index-/]
      options[:attribution] = <<-HTML
        Scala programming documentation. Copyright (c) 2003-2013 <a
        href="http://www.epfl.ch" target="_blank">EPFL</a>, with contributions from <a
        href="http://typesafe.com" target="_blank">Typesafe</a>.
      HTML
      html_filters.push 'scala/entries', 'scala/clean_html'
    end
  end
end
