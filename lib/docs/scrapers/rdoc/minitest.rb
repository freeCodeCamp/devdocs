module Docs
  class Minitest < Rdoc

    self.name = 'Ruby / Minitest'
    self.slug = 'minitest'
    self.release = '5.25.4'
    self.links = {
      code: 'https://github.com/minitest/minitest'
    }
    self.base_url = 'https://docs.seattlerb.org/minitest/'

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
