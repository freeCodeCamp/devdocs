module Docs
  class Ember < UrlScraper
    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.release = '2.7.0'
    self.base_url = 'http://emberjs.com/api/'
    self.links = {
      home: 'http://emberjs.com/',
      code: 'https://github.com/emberjs/ember.js'
    }

    html_filters.push 'ember/clean_html', 'ember/entries', 'title'

    options[:title] = false
    options[:root_title] = 'Ember.js'

    options[:container] = ->(filter) do
      filter.root_page? ? '#toc-list' : '#content'
    end

    # Duplicates
    options[:skip] = %w(classes/String.html data/classes/DS.html)

    options[:skip_patterns] = [/\._/]

    options[:attribution] = <<-HTML
      &copy; 2016 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML
  end
end
