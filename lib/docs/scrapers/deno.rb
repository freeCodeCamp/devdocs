module Docs
  class Deno < UrlScraper
    self.name = 'Deno'
    self.type = 'simple'
    self.links = {
      home: 'https://deno.com/',
      code: 'https://github.com/denoland/deno'
    }

    # https://github.com/denoland/manual/blob/main/LICENSE
    # https://github.com/denoland/deno/blob/main/LICENSE.md
    options[:attribution] = <<-HTML
      &copy; 2018–2025 the Deno authors<br>
      Licensed under the MIT License.
    HTML


    html_filters.push 'deno/entries', 'deno/clean_html'

    version '2' do
      self.release = '2.4.4'
      self.base_url = 'https://docs.deno.com/'
      self.root_path = 'runtime'
      options[:only_patterns] = [/\Aruntime/, /\Aapi\/deno\/~/, /\Adeploy/, /\Asubhosting/]
      options[:skip_patterns] = [
        /\Aruntime\/manual/,
        /\Aapi\/deno\/.+\.prototype\z/, # all prototype pages get redirected to the main page
        /\Aapi\/deno\/~\/Deno\.jupyter\.MediaBundle.+/, # docs unavailable
        /\Aapi\/deno\/~\/Deno\.OpMetrics/, # deprecated in deno 2
      ]
      options[:trailing_slash] = false
    end

    version '1' do
      self.release = '1.27.0'
    end

    def get_latest_version(opts)
      get_latest_github_release('denoland', 'deno', opts)
    end
  end
end
