module Docs
  class ReactNative < UrlScraper
    self.slug = 'react_native'
    self.type = 'react_native'
    self.release = '0.62'
    self.base_url = 'https://reactnative.dev/docs/'
    self.root_path = 'getting-started'
    self.links = {
      home: 'https://reactnative.dev/',
      code: 'https://github.com/facebook/react-native'
    }

    html_filters.push 'react_native/entries', 'react_native/clean_html'

    options[:container] = '.docMainWrapper'
    options[:skip_patterns] = [/\Asample\-/, /\Anext/]
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
      &copy; 2015&ndash;2020 Facebook Inc.<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://reactnative.dev/docs/getting-started', opts)
      doc.at_css('header > a > h3').content
    end
  end
end
