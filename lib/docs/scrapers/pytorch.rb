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
    options[:max_image_size] = 1_000_000

    options[:attribution] = <<-HTML
    &copy; 2025, PyTorch Contributors<br>
    PyTorch has a BSD-style license, as found in the <a href="https://github.com/pytorch/pytorch/blob/main/LICENSE">LICENSE</a> file.
    HTML

    version '2.7' do
      self.release = '2.7'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.6' do
      self.release = '2.6'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.5' do
      self.release = '2.5'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.4' do
      self.release = '2.4'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.3' do
      self.release = '2.3'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.2' do
      self.release = '2.2'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.1' do
      self.release = '2.1'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.0' do
      self.release = '2.0'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '1.13' do
      self.release = '1.13'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    def get_latest_version(opts)
      get_latest_github_release('pytorch', 'pytorch', opts)
    end
  end
end
