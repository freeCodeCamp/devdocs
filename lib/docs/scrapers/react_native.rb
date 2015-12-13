module Docs
  class ReactNative < React
    self.name = 'React Native'
    self.slug = 'react_native'
    self.type = 'react'
    self.version = '0.16'
    self.base_url = 'https://facebook.github.io/react-native/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://facebook.github.io/react-native/',
      code: 'https://github.com/facebook/react-native'
    }

    options[:root_title] = 'React Native Documentation'
    options[:only_patterns] = nil
    options[:skip] = %w(
      videos.html
      transforms.html
      troubleshooting.html)

    options[:attribution] = <<-HTML
      &copy; 2015 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
