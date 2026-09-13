module Docs
  class Homebrew < UrlScraper
    # include MultipleBaseUrls

    self.name = 'Homebrew'
    self.type = 'simple'
    self.release = '6.0.3'
    self.base_url = 'https://docs.brew.sh/'
    self.links = {
      home: 'https://brew.sh',
      code: 'https://github.com/Homebrew/brew'
    }

    html_filters.push 'homebrew/entries', 'homebrew/clean_html'

    options[:container] = ->(filter) do
      if filter.current_url.path.include?('rubydoc')
        '#content'
      else
        '#default'
      end
    end

    # Mostly handbook articles with no code.
    options[:skip_patterns] = [
      /maintainer/i,
      /core\-contributor/i,
      /kickstarter/i,
      /governance/i,
      /responsible/i,
      /leadership/i,
      /prose/i,
      /expense/i,
      /creating-a-homebrew-issue/i,
      /homebrew-and-java/i,
      /checksum_deprecation/i,
      /Working-with/i
    ]

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;present Homebrew contributors<br>
      Licensed under the BSD 2-Clause License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('Homebrew', 'brew', opts)
    end
  end
end
