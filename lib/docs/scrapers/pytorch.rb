module Docs
  class Pytorch < UrlScraper
    self.name = 'PyTorch'
    self.slug = 'pytorch'
    self.type = 'sphinx'
    self.force_gzip = true
    self.links = {
      home: 'https://pytorch.org/',
      code: 'https://github.com/pytorch/pytorch'
    }

    html_filters.push 'pytorch/entries', 'pytorch/clean_html', 'sphinx/clean_html'

    options[:skip] = ['cpp_index.html', 'packages.html', 'py-modindex.html', 'genindex.html']
    options[:skip_patterns] = [/\Acommunity/, /\A_modules/, /\Anotes/, /\Aorg\/pytorch\//]
    options[:max_image_size] = 256_000

    options[:attribution] = <<-HTML
    &copy; 2019 Torch Contributors<br>
    Licensed under the 3-clause BSD License.
    HTML

    version do
      self.release = '1.8.0'
      self.base_url = "https://pytorch.org/docs/#{release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pytorch', 'pytorch', opts)
    end
  end
end
