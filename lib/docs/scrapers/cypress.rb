# frozen_string_literal: true

module Docs
  class Cypress < UrlScraper
    # Follow the instructions on https://github.com/cypress-io/cypress-documentation/blob/develop/CONTRIBUTING.md
    # to run the cypress documentation server locally in the following URL:
    # self.base_url = 'http://localhost:2222'
    self.base_url = 'https://docs.cypress.io'

    self.name = 'Cypress'
    self.type = 'cypress'
    self.root_path = '/api/api/table-of-contents.html'

    html_filters.push 'cypress/clean_html', 'cypress/entries'

    options[:root_title] = 'Cypress'
    options[:container] = '#content'

    options[:include_default_entry] = true

    options[:skip_link] = lambda do |link|
      href = link.attr(:href)

      EntriesFilter::SECTIONS.none? { |section| href.match?("/#{section}/") }
    end

    options[:attribution] = <<-HTML
      © 2018 <a href="https://cypress.io">Cypress.io</a>
      - Licensed under the
      <a href="https://github.com/cypress-io/cypress-documentation/blob/develop/LICENSE.md">MIT License</a>.
    HTML
  end
end
