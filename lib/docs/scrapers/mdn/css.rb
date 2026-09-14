module Docs
  class Css < MdnGit
    # release = '2026-09-14'
    self.name = 'CSS'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/CSS/Reference'
    self.content_path = 'web/css/reference'
    self.slug_prefix = 'Web/CSS/Reference'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/CSS',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/css'
    }

    # The formal syntax and the table of characteristics of a property are
    # MDN's, not its authors'.
    self.data_packages = data_packages.merge('mdn-data' => 'mdn-data')

    html_filters.push 'css/entries'

    options[:root_title] = 'CSS'
  end
end
