module Docs
  class Flow < React
    self.type = 'react'
    self.version = '0.18'
    self.base_url = 'http://flowtype.org/docs/'
    self.root_path = 'about-flow.html'
    self.links = {
      home: 'http://flowtype.org/',
      code: 'https://github.com/facebook/flow'
    }

    options[:container] = '.content'
    options[:root_title] = 'Flow Documentation'
    options[:only_patterns] = nil
    options[:skip] = %w(coming-soon.html)

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2015 Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
