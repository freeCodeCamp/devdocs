module Docs
  class Prettier < Docusaurus
    self.base_url = 'https://prettier.io/docs/en/'
    self.root_path = 'index.html'
    self.release = '1.15.2'
    self.links = {
      home: 'https://prettier.io/',
      code: 'https://github.com/prettier/prettier'
    }

    options[:trailing_slash] = false

    options[:attribution] = <<-HTML
      &copy; 2017&ndash;2018 James Long<br>
      Licensed under the MIT license.
    HTML
  end
end
