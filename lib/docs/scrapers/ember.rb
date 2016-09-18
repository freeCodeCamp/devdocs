module Docs
  class Ember < UrlScraper
    include MultipleBaseUrls

    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.release = '2.7.0'
    self.base_urls = ['http://emberjs.com/api/', "https://guides.emberjs.com/v#{self.release}/"]
    self.links = {
      home: 'http://emberjs.com/',
      code: 'https://github.com/emberjs/ember.js'
    }

    html_filters.push 'ember/entries', 'ember/clean_html', 'title'

    options[:trailing_slash] = false

    options[:title] = false
    options[:root_title] = 'Ember.js'

    options[:container] = ->(filter) do
      if filter.base_url.path.start_with?('/api')
        filter.root_page? ? '#toc-list' : '#content'
      else
        'main'
      end
    end

    # Duplicates
    options[:skip] = %w(classes/String.html data/classes/DS.html)
    options[:skip_patterns] = [/\._/, /contributing/]

    options[:attribution] = <<-HTML
      &copy; 2016 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
