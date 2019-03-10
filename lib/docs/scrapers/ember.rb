module Docs
  class Ember < UrlScraper
    include MultipleBaseUrls

    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.release = '2.15.0'
    self.base_urls = [
      'https://guides.emberjs.com/v2.15.0/',
      'https://emberjs.com/api/ember/2.15/',
      'https://emberjs.com/api/ember-data/2.14/'
    ]
    self.links = {
      home: 'https://emberjs.com/',
      code: 'https://github.com/emberjs/ember.js'
    }

    html_filters.push 'ember/entries', 'ember/clean_html'

    options[:trailing_slash] = false

    options[:container] = ->(filter) do
      if filter.base_url.path.start_with?('/api')
        'main article'
      else
        'main'
      end
    end

    options[:fix_urls] = ->(url) do
      url.sub! '?anchor=', '#'
      url.sub! %r{/methods/[^?#/]+}, '/methods'
      url.sub! %r{/properties/[^?#/]+}, '/properties'
      url.sub! %r{/events/[^?#/]+}, '/events'
      url
    end

    options[:skip_patterns] = [
      /\._/,
      /contributing/,
      /classes\/String/,
      /namespaces\/Ember/,
      /namespaces\/DS/
    ]

    options[:attribution] = <<-HTML
      &copy; 2017 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML

    def initial_urls
      %w(
        https://guides.emberjs.com/v2.15.0/
        https://emberjs.com/api/ember/2.15/classes/Ember
        https://emberjs.com/api/ember-data/2.14/classes/DS
      )
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://emberjs.com/api/ember/release', opts)
      doc.at_css('.sidebar > .select-container .ember-power-select-selected-item').content.strip
    end
  end
end
