module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'simple'
    self.links = {
      home: 'https://react.dev/',
      code: 'https://github.com/facebook/react'
    }

    version do
      self.release = '18.3.1'
      # TODO add /learn
      self.base_url = 'https://react.dev/reference'

      html_filters.push 'react/entries_react_dev', 'react/clean_html_react_dev'

      options[:attribution] = <<-HTML
        &copy; 2013&ndash;present Facebook Inc.<br>
        Licensed under the Creative Commons Attribution 4.0 International Public License.
      HTML
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

      options[:attribution] = <<-HTML
        &copy; 2013&ndash;present Facebook Inc.<br>
        Licensed under the Creative Commons Attribution 4.0 International Public License.
      HTML
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://react.dev/', opts)
      doc.at_css('a[href="/versions"]').content.strip[1..-1]
    end
  end
end
