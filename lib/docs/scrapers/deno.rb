module Docs
  class Deno < UrlScraper
    self.name = 'Deno'
    self.type = 'simple'
    self.release = '1.46.3'
    self.base_url = 'https://docs.deno.com/api/deno/'
    self.links = {
      home: 'https://deno.com',
      code: 'https://github.com/denoland/deno'
    }

    html_filters.push 'deno/entries', 'deno/clean_html'

    # https://github.com/denoland/manual/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2018–2024 the Deno authors
    HTML

    def get_latest_version(opts)
      get_latest_github_release('denoland', 'deno', opts)
      end
  end
end
