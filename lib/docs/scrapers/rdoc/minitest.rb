module Docs
  class Minitest < Rdoc
    self.name = 'Ruby / Minitest'
    self.slug = 'minitest'
    self.release = '5.10.3'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Minitest' # rake docs
    self.links = {
      code: 'https://github.com/seattlerb/minitest'
    }

    html_filters.replace 'rdoc/entries', 'minitest/entries'

    options[:root_title] = 'Minitest'

    options[:attribution] = <<-HTML
      &copy; Ryan Davis, seattle.rb<br>
      Licensed under the MIT License.
    HTML
  end
end
