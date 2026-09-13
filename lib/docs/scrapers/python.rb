module Docs
  class Python < FileScraper
    self.type = 'python'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.python.org/',
      code: 'https://github.com/python/cpython'
    }

    # bypass the clean_text filter as it removes empty span with ids
    options[:clean_text] = false

    # bypass sphinx modifying empty ids
    options[:sphinx_keep_empty_ids] = true

    # The downloadable archives are linked from the docs but aren't part of them
    options[:skip_patterns] = [/whatsnew/, %r{\Aarchives/}]
    options[:skip] = %w(
      library/2to3.html
      library/formatter.html
      library/intro.html
      library/undoc.html
      library/unittest.mock-examples.html
      library/sunau.html)

    options[:attribution] = <<-HTML
      &copy; 2001 Python Software Foundation<br>
      Licensed under the PSF License.
    HTML

    version '3.14' do
      self.release = '3.14.7'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.13' do
      self.release = '3.13.8'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.12' do
      self.release = '3.12.9'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.11' do
      self.release = '3.11.11'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.10' do
      self.release = '3.10.13'
      self.base_url = "https://docs.python.org/#{self.version}/"

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.9' do
      self.release = '3.9.14'
      self.base_url = 'https://docs.python.org/3.9/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.8' do
      self.release = '3.8.14'
      self.base_url = 'https://docs.python.org/3.8/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.7' do
      self.release = '3.7.14'
      self.base_url = 'https://docs.python.org/3.7/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.6' do
      self.release = '3.6.12'
      self.base_url = 'https://docs.python.org/3.6/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '3.5' do
      self.release = '3.5.9'
      self.base_url = 'https://docs.python.org/3.5/'

      html_filters.push 'python/entries_v3', 'sphinx/clean_html', 'python/clean_html'
    end

    version '2.7' do
      self.release = '2.7.17'
      self.base_url = 'https://docs.python.org/2.7/'

      html_filters.push 'python/entries_v2', 'sphinx/clean_html', 'python/clean_html'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.python.org/', opts)
      doc.at_css('title').content.split(' ')[0]
    end

    private

    # Maintained branches publish the archive under their version, while
    # branches that have reached EOL keep the one built from their last release.
    def archive_url
      @archive_url ||= [self.class.version, self.class.release].map { |name|
        "https://docs.python.org/#{self.class.version}/archives/python-#{name}-docs-html.tar.bz2"
      }.find { |url| Request.run(url, method: :head).success? }
    end

    def download_source
      raise SetupError, "No documentation archive found for Python #{self.class.release}." if archive_url.nil?

      # The archive expands to a single directory named after itself.
      download_and_extract(archive_url, File.basename(archive_url, '.tar.bz2'))
    end
  end
end
