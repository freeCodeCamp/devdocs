module Docs
  class ReactNative < UrlScraper
    self.name = 'React Native'
    self.slug = 'react_native'
    self.type = 'react_native'
    self.release = '0.69'
    self.base_url = 'https://reactnative.dev/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://reactnative.dev/',
      code: 'https://github.com/facebook/react-native'
    }

    html_filters.push 'react_native/entries', 'react_native/clean_html'

    options[:skip_patterns] = [/\Asample\-/, /\A0\./, /\Anext\b/]
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

    # https://github.com/facebook/react-native-website/blob/main/LICENSE-docs
    options[:attribution] = <<-HTML
      &copy; 2022 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://reactnative.dev/docs/getting-started', opts)
      doc.at_css('meta[name="docsearch:version"]')['content']
    end
  end
end
