module Docs
  class I3 < UrlScraper
    self.name = 'i3'
    self.type = 'simple'
    self.slug = 'i3'
    self.release = '4.22'
    self.base_url = 'https://i3wm.org/docs/userguide.html'
    self.links = {
      home: 'https://i3wm.org/',
      code: 'https://github.com/i3/i3'
    }

    html_filters.push 'i3/entries', 'title'

    options[:container] = 'main'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009, Michael Stapelberg and contributors
    HTML

    def get_latest_version(opts)
        tags = get_github_tags('i3', 'i3', opts)
        tag = tags.find {|tag| tag['name'].start_with?('4.')}
        tag['name']
      end
  end
end
