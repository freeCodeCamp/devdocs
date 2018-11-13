module Docs
  class ReactNative < Docusaurus
    self.name = 'React Native'
    self.slug = 'react_native'
    self.type = 'react_native'
    self.release = '0.57'
    self.base_url = 'https://facebook.github.io/react-native/docs/'
    self.root_path = 'getting-started'
    self.links = {
      home: 'https://facebook.github.io/react-native/',
      code: 'https://github.com/facebook/react-native'
    }

    html_filters.push 'react_native/entries', 'react_native/clean_html'

    options[:container] = '.docMainWrapper'
    options[:skip_patterns] = [/\Asample\-/]
    options[:skip] = %w(
      more-resources
    )

    options[:fix_urls] = ->(url) {
      url.sub! 'docs/docs', 'docs'
      url
    }

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2018 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
