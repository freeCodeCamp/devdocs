module Docs
  class Minitest < Rdoc
    # Instructions:
    #   1. Run "gem update rdoc hoe"
    #   2. Download the source code at https://github.com/seattlerb/minitest
    #   3. Run "rake docs" (in the Minitest directory)
    #   4. Copy the "docs" directory to "docs/minitest"

    self.name = 'Ruby / Minitest'
    self.slug = 'minitest'
    self.release = '5.11.3'
    self.links = {
      code: 'https://github.com/seattlerb/minitest'
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
