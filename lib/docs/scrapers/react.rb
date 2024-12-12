module Docs
  class React < UrlScraper

    self.name = 'React'
    self.type = 'react'
    self.links = {
      home: 'https://react.dev/',
      code: 'https://github.com/facebook/react'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;present Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML

    version do
      self.release = '19'
      self.base_url = 'https://react.dev'
      self.initial_paths = %w(/reference/react /learn)
      html_filters.push 'react/entries_react_dev', 'react/clean_html_react_dev'

      options[:only_patterns] = [/\A\/learn/, /\A\/reference/]
    end

    version '18' do
      self.release = '18.3.1'
      self.base_url = 'https://18.react.dev'
      self.initial_paths = %w(/reference/react /learn)
      html_filters.push 'react/entries_react_dev', 'react/clean_html_react_dev'

      options[:only_patterns] = [/\A\/learn/, /\A\/reference/]
    end

    version '17' do
      self.release = '17.0.2'
      self.base_url = 'https://17.reactjs.org/docs/'
      self.root_path = 'hello-world.html'
      html_filters.push 'react/entries', 'react/clean_html'

      options[:skip] = %w(
        codebase-overview.html
        design-principles.html
        how-to-contribute.html
        implementation-notes.html
      )

      options[:replace_paths] = {
        'more-about-refs.html' => 'refs-and-the-dom.html',
        'interactivity-and-dynamic-uis.html' => 'state-and-lifecycle.html',
        'working-with-the-browser.html' => 'refs-and-the-dom.html',
        'top-level-api.html' => 'react-api.html',
      }
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://react.dev/', opts)
      doc.at_css('a[href="/versions"]').content.strip[1..-1]
    end
  end
end
