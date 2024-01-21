module Docs
  class Pytorch < UrlScraper
    self.name = 'PyTorch'
    self.slug = 'pytorch'
    self.type = 'sphinx'
    self.links = {
      home: 'https://pytorch.org/',
      code: 'https://github.com/pytorch/pytorch'
    }

    html_filters.push 'pytorch/entries', 'pytorch/clean_html', 'sphinx/clean_html'

    options[:skip] = ['cpp_index.html', 'deploy.html', 'packages.html', 'py-modindex.html', 'genindex.html']
    options[:skip_patterns] = [/\Acommunity/, /\A_modules/, /\Anotes/, /\Aorg\/pytorch\//]

    options[:attribution] = <<-HTML
    &copy; 2024, PyTorch Contributors<br>
    PyTorch has a BSD-style license, as found in the <a href="https://github.com/pytorch/pytorch/blob/main/LICENSE">LICENSE</a> file.
    HTML

    version '2' do
      self.release = '2.1'
      self.base_url = "https://pytorch.org/docs/#{release}/"
    end

    version '1' do
      self.release = '1.13'
      self.base_url = "https://pytorch.org/docs/#{release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pytorch', 'pytorch', opts)
    end
  end
end
