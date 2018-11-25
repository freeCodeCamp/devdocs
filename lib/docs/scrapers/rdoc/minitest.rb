module Docs
  class Minitest < Rdoc
     # Run "rake docs" in the gem directory
    self.name = 'Ruby / Minitest'
    self.slug = 'minitest'
    self.release = '5.10.3'
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
