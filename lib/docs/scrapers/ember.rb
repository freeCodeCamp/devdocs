module Docs
  class Ember < UrlScraper
    class << self
      attr_accessor :guide_url
    end

    self.name = 'Ember.js'
    self.slug = 'ember'
    self.type = 'ember'
    self.release = '2.7.0'
    self.base_url = 'http://emberjs.com/api/'
    self.guide_url = "https://guides.emberjs.com/v#{self.release}/"
    self.initial_urls = [guide_url]
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

    def guide_url
      @guide_url ||= URL.parse(self.class.guide_url)
    end

    private

    def process_url?(url)
      base_url.contains?(url) || guide_url.contains?(url)
    end

    def process_response(response)
      original_scheme = @base_url.scheme
      original_host = @base_url.host
      original_path = @base_url.path
      @base_url.scheme = response.effective_url.scheme
      @base_url.host = response.effective_url.host
      @base_url.path = response.effective_url.path[/\A\/v[\d\.]+\//, 0] || '/api/'
      super
    ensure
      @base_url.scheme = original_scheme
      @base_url.host = original_host
      @base_url.path = original_path
    end
  end
end
