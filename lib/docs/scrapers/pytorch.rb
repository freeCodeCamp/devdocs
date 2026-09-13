module Docs
  class Pytorch < FileScraper
    self.name = 'PyTorch'
    self.slug = 'pytorch'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://pytorch.org/',
      code: 'https://github.com/pytorch/pytorch'
    }

    html_filters.push 'pytorch/entries', 'pytorch/clean_html', 'sphinx/clean_html'

    options[:skip] = ['cpp_index.html', 'deploy.html', 'packages.html', 'py-modindex.html', 'genindex.html']
    options[:skip_patterns] = [
      /.*(?<!\.html)\z/, # non-HTML files, e.g. the .md sources shipped next to each page
      /\Acommunity/,
      /\A_modules/,
      /\Anotes/,
      /\Aorg\/pytorch\//
    ]
    options[:max_image_size] = 1_000_000

    options[:attribution] = <<-HTML
    &copy; 2026, PyTorch Contributors<br>
    PyTorch has a BSD-style license, as found in the <a href="https://github.com/pytorch/pytorch/blob/main/LICENSE">LICENSE</a> file.
    HTML

    version '2.14' do
      self.release = '2.14'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.13' do
      self.release = '2.13'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.12' do
      self.release = '2.12'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.11' do
      self.release = '2.11'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.10' do
      self.release = '2.10'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.9' do
      self.release = '2.9'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

    version '2.8' do
      self.release = '2.8'
      self.base_url = "https://docs.pytorch.org/docs/#{release}/"
    end

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

    private

    # There is no documentation archive, the files have to be taken from the
    # repository hosting https://docs.pytorch.org.
    def download_source
      require 'tmpdir'

      Dir.mktmpdir do |directory|
        repository = File.join(directory, 'docs')

        instrument 'info.doc', msg: %(Cloning the PyTorch #{self.class.version} documentation...)
        # The "site" branch holds the rendered documentation of every version,
        # of which only the one being scraped is checked out.
        system('git', 'clone', '--branch', 'site', '--depth', '1', '--filter=blob:none', '--sparse',
               'https://github.com/pytorch/docs', repository)
        system('git', '-C', repository, 'sparse-checkout', 'set', self.class.version)

        instrument 'info.doc', msg: %(Moving the documentation files to "#{source_directory}"...)
        FileUtils.mkpath(File.dirname(source_directory))
        FileUtils.mv(File.join(repository, self.class.version), source_directory)
      end
    end
  end
end
