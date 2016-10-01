module Docs
  class Flow < React
    self.type = 'react'
    self.release = '0.33'
    self.base_url = 'https://flowtype.org/docs/'
    self.root_path = 'getting-started.html'
    self.links = {
      home: 'https://flowtype.org/',
      code: 'https://github.com/facebook/flow'
    }

    options[:container] = '.content'
    options[:root_title] = 'Flow Documentation'
    options[:only_patterns] = nil

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Facebook Inc.<br>
      Licensed under the BSD License.
    HTML
  end
end
