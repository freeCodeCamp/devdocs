module Docs
  class React < UrlScraper
    self.name = 'React'
    self.type = 'react'
    self.release = '15.5.0'
    self.base_url = 'https://facebook.github.io/react/docs/'
    self.root_path = 'hello-world.html'
    self.links = {
      home: 'https://facebook.github.io/react/',
      code: 'https://github.com/facebook/react'
    }

    html_filters.push 'react/entries', 'react/clean_html'

    options[:root_title] = 'React Documentation'
    options[:container] = '.documentationContent'

    options[:replace_paths] = {
      'top-level-api.html' => 'react-api.html',
      'working-with-the-browser.html' => 'refs-and-the-dom.html',
      'interactivity-and-dynamic-uis.html' => 'state-and-lifecycle.html',
      'more-about-refs.html' => 'refs-and-the-dom.html',
      'advanced-performance.html' => 'optimizing-performance.html',
      'component-api.html' => 'react-component.html',
      'component-specs.html' => 'react-component.html',
      'multiple-components.html' => 'composition-vs-inheritance.html',
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2017 Facebook Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International Public License.
    HTML
  end
end
