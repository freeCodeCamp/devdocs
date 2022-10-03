module Docs
  class Numpy < FileScraper
    self.name = 'NumPy'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.numpy.org/',
      code: 'https://github.com/numpy/numpy'
    }

    html_filters.push 'numpy/entries', 'numpy/clean_html', 'sphinx/clean_html'

    # .main contains more than the page's content alone, but we need something
    # that includes the navigation bar as well in order to guess the type of
    # most pages.
    options[:container] = '.main'

    options[:skip_patterns] = [
      /.*(?<!\.html)\z/,
      /\Arelease\/.*-notes.html\Z/,
      /\Agenerated\/numpy\.chararray\.[\w\-]+.html\z/ # duplicate
    ]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2022 NumPy Developers<br>
      Licensed under the 3-clause BSD License.
    HTML

    version '1.23' do
      self.release = '1.23.0'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
      options[:container] = nil
    end

    version '1.22' do
      self.release = '1.22.4'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
      options[:container] = nil
    end

    version '1.21' do
      self.release = '1.21.6'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
      options[:container] = nil
    end

    version '1.20' do
      self.release = '1.20.3'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
      options[:container] = nil
    end

    version '1.19' do
      self.release = '1.19.0'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
    end

    version '1.18' do
      self.release = '1.18.5'
      self.base_url = "https://numpy.org/doc/#{self.version}/"
    end

    version '1.17' do
      self.release = '1.17.0'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.16' do
      self.release = '1.16.1'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.15' do
      self.release = '1.15.4'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.14' do
      self.release = '1.14.5'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.13' do
      self.release = '1.13.0'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.12' do
      self.release = '1.12.0'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.11' do
      self.release = '1.11.0'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    version '1.10' do
      self.release = '1.10.4'
      self.base_url = "https://docs.scipy.org/doc/numpy-#{self.release}/reference/"
    end

    def get_latest_version(opts)
      get_latest_github_release('numpy', 'numpy', opts)
    end
  end
end
