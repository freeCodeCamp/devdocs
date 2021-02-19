# frozen_string_literal: true

module Docs
  class Ember < UrlScraper
    include MultipleBaseUrls

    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.release = '3.25.0'
    self.base_urls = %w[
      https://guides.emberjs.com/v3.25.0/
      https://api.emberjs.com/ember/3.25/
      https://api.emberjs.com/ember-data/3.25/
    ]
    self.links = {
      home: 'https://emberjs.com/',
      code: 'https://github.com/emberjs/ember.js'
    }

    html_filters.push 'ember/entries', 'ember/clean_html'

    options[:trailing_slash] = false

    options[:container] = ->(filter) do
      if filter.base_url.host.start_with?('api')
        'main'
      else
        'main article'
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
      /tutorial/,
      /js-primer/,
      /in-depth-topics$/,
      /managing-dependencies$/
    ]

    options[:attribution] = <<-HTML
      &copy; 2020 Yehuda Katz, Tom Dale and Ember.js contributors<br>
      Licensed under the MIT License.
    HTML

    options[:decode_and_clean_paths] = true # handle paths like @ember/application

    def initial_urls
      %w(
        https://guides.emberjs.com/v3.25.0/
        https://api.emberjs.com/ember/3.25/
        https://api.emberjs.com/ember-data/3.25/
      )
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://api.emberjs.com/ember/release', opts)
      doc.at_css('.sidebar > .select-container .ember-power-select-selected-item').content.strip
    end
  end
end
