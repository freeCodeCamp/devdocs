module Docs
  class ReactNative < UrlScraper
    self.slug = 'react_native'
    self.type = 'react_native'
    self.release = '0.56'
    self.base_url = 'https://facebook.github.io/react-native/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/react-native/',
      code: 'https://github.com/facebook/react-native'
    }

    html_filters.push 'react_native/entries', 'react_native/clean_html'

    options[:container] = '.docMainWrapper'
    options[:skip_patterns] = [/\Asample\-/]
    options[:skip] = %w(
      videos.html
      transforms.html
      troubleshooting.html
      more-resources.html
    )

    options[:fix_urls] = ->(url) {
      url.sub! 'docs/docs', 'docs'
      url
    }

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2018 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://facebook.github.io/react-native/docs/getting-started.html', opts)
      doc.at_css('header > a > h3').content
    end
  end
end
