module Docs
  class Webpack < UrlScraper
    self.name = 'webpack'
    self.type = 'webpack'

    self.root_path = 'guides/'
    self.initial_paths = %w(
      concepts/
      guides/
      api/
      configuration/
      loaders/
      plugins/
    )
    self.links = {
      home: 'https://webpack.js.org/',
      code: 'https://github.com/webpack/webpack'
    }

    html_filters.push 'webpack/clean_html', 'webpack/entries'

    options[:container] = '.page'
    options[:trailing_slash] = false
    options[:only_patterns] = [
      /\Aconcepts\//,
      /\Aguides\//,
      /\Aapi\//,
      /\Aconfiguration\//,
      /\Aloaders\//,
      /\Aplugins\//
    ]

    options[:attribution] = <<-HTML
      &copy; JS Foundation and other contributors<br>
      Licensed under the Creative Commons Attribution License 4.0.
    HTML

    version '5' do
      self.release = '5.6.0'
      self.base_url = 'https://webpack.js.org/'
    end

    version '4' do
      self.release = '4.44.2'
      self.base_url = 'https://v4.webpack.js.org/'
    end

    version '1' do
      self.release = '1.15.0'
      self.base_url = 'https://webpack.github.io/docs/'
      self.links = {
        home: 'https://webpack.github.io/',
        code: 'https://github.com/webpack/webpack/tree/webpack-1'
      }

      html_filters.push 'webpack/entries_old', 'webpack/clean_html_old', 'title'

      options[:title] = false
      options[:root_title] = 'webpack'

      options[:skip] = %w(list-of-tutorials.html examples.html changelog.html ideas.html roadmap.html)

      options[:attribution] = <<-HTML
        &copy; 2012&ndash;2015 Tobias Koppers<br>
        Licensed under the MIT License.
      HTML
    end

    def get_latest_version(opts)
      get_npm_version('webpack', opts)
    end
  end
end
