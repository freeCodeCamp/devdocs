module Docs
  class Deno < UrlScraper
    self.name = 'Deno'
    self.type = 'simple'
    self.release = '1.27.0'
    self.base_url = 'https://doc.deno.land/deno/stable/'
    self.links = {
      home: 'https://deno.land/',
      code: 'https://github.com/denoland/deno'
    }

    html_filters.push 'deno/entries', 'deno/clean_html'

    # https://github.com/denoland/manual/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2018–2022 the Deno authors
    HTML

    def get_latest_version(opts)
      get_latest_github_release('denoland', 'deno', opts)
      end
  end
end
