module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'simple'
    self.release = '18.2.0'
    self.base_url = 'https://reactjs.org/docs/'
    self.root_path = 'hello-world.html'
    self.links = {
      home: 'https://reactjs.org/',
      code: 'https://github.com/facebook/react'
    }

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

    def get_latest_version(opts)
      doc = fetch_doc('https://reactjs.org/docs/getting-started.html', opts)
      doc.at_css('a[href="/versions"]').content.strip[1..-1]
    end
  end
end
