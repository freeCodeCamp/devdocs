module Docs
  class Play < FileScraper
    include FixInternalUrlsBehavior

    self.name = 'play'
    self.type = 'play'

    self.links = {
      home: 'https://playframework.com',
      code: 'https://github.com/playframework/playframework'
    }
    self.root_path = 'package.html'

    options[:attribution] = <<-HTML
      <p>Copyright (C) 2009-2017 Lightbend Inc. (<a href="https://www.lightbend.com">https://www.lightbend.com</a>).</p>
      <p>Licensed under the Apache License, Version 2.0 (the "License"); you may not use this project except in compliance with the License. You may obtain a copy of the License at <a href="http://www.apache.org/licenses/LICENSE-2.0">http://www.apache.org/licenses/LICENSE-2.0</a>.</p>
    HTML
    options[:skip_patterns] = [/^index.html/, /index\/index-/]
    html_filters.push 'scala/entries', 'scala/clean_html'

    version 'Scala API 2.4' do
      self.release = '2.4.11'
      self.base_url = 'https://playframework.com/documentation/2.4.11/api/scala/'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Play24/docs/content/api/scala' # download from http://central.maven.org/maven2/com/typesafe/play/play-docs_2.11/2.4.11/play-docs_2.11-2.4.11.jar
    end

    version 'Scala API 2.5' do
      self.release = '2.5.18'
      self.base_url = 'https://playframework.com/documentation/2.5.18/api/scala/'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Play25/docs/content/api/scala' # download from http://central.maven.org/maven2/com/typesafe/play/play-docs_2.11/2.5.18/play-docs_2.11-2.5.18.jar
    end

    version 'Scala API 2.6' do
      self.release = '2.6.6'
      self.base_url = 'https://playframework.com/documentation/2.6.6/api/scala/'
      self.dir = '/Users/Thibaut/DevDocs/Docs/Play26/docs/content/api/scala' # Download from http://central.maven.org/maven2/com/typesafe/play/play-docs_2.11/2.6.6/play-docs_2.11-2.6.6.jar
    end
  end
end
