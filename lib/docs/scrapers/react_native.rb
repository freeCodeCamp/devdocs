module Docs
  class ReactNative < React
    self.name = 'React Native'
    self.slug = 'react_native'
    self.type = 'react'
    self.release = '0.48'
    self.base_url = 'https://facebook.github.io/react-native/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/react-native/',
      code: 'https://github.com/facebook/react-native'
    }

    html_filters.replace 'react/entries', 'react_native/entries'
    html_filters.push 'react_native/clean_html'

    options[:root_title] = 'React Native Documentation'
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
      &copy; 2015&ndash;2017 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
