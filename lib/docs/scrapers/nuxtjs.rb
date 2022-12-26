module Docs
  class Nuxtjs < UrlScraper
    self.name = 'NuxtJS'
    self.name = 'nuxtjs'
    self.type = 'nuxtjs'
    self.release = '2.15.8'
    self.base_url = 'https://nuxtjs.org/docs/'
    self.root_path = 'get-started/installation'

    self.links = {
      home: 'https://nuxtjs.org/',
      code: 'https://github.com/nuxt/nuxt.js'
    }

    html_filters.push 'nuxtjs/container', 'nuxtjs/entries', 'nuxtjs/clean_html'

    options[:only_patterns] = [
      /\Aget-started\//, /\Aconcepts\//, /\Afeatures\//,
      /\Adirectory-structure\//, /\Aconfiguration-glossary\//, /\Ainternals-glossary\//
    ]
    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; This project is licensed under the terms of the MIT license.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('nuxt', 'nuxt.js', opts)
    end
  end
end
