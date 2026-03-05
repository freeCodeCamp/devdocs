module Docs
  class Minitest < Rdoc

    self.name = 'Ruby / Minitest'
    self.slug = 'minitest'
    self.release = '6.0.1'
    self.links = {
      home: 'https://minite.st',
      code: 'https://github.com/minitest/minitest'
    }

    html_filters.replace 'rdoc/entries', 'minitest/entries'

    options[:root_title] = 'Minitest'

    options[:attribution] = <<-HTML
      &copy; Ryan Davis, seattle.rb<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      contents = get_github_file_contents('seattlerb', 'minitest', 'History.rdoc', opts)
      contents.scan(/([0-9.]+)/)[0][0]
    end
  end
end
