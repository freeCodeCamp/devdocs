# frozen_string_literal: true

module Docs
  class Cypress < UrlScraper
    self.name = 'Cypress'
    self.type = 'cypress'
    self.release = '6.1.0'
    self.base_url = 'https://docs.cypress.io'
    self.root_path = '/api/api/table-of-contents.html'
    self.links = {
      home: 'https://www.cypress.io/',
      code: 'https://github.com/cypress-io/cypress',
    }

    html_filters.push 'cypress/entries', 'cypress/clean_html'

    options[:container] = '#content'
    options[:max_image_size] = 300_000
    options[:include_default_entry] = true

    options[:skip_patterns] = [
      /examples\//,
      /guides/
    ]

    options[:skip_link] = ->(link) {
      href = link.attr(:href)
      href.nil? ? true : EntriesFilter::SECTIONS.none? { |section| href.match?("/#{section}/") }
    }

    options[:attribution] = <<-HTML
      &copy; 2020 Cypress.io<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('cypress-io', 'cypress', opts)
    end
  end
end
