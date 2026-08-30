module Docs
  class Dart < FileScraper
    self.type = 'dart'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://dart.dev/',
      code: 'https://github.com/dart-lang/sdk'
    }

    html_filters.push 'dart/entries', 'dart/clean_html'

    options[:fix_urls] = ->(url) do
      # localhost/dart-web_audio/..dart-io/dart-io-library.html > localhost/dart-io/dart-io-library.html
      url.remove!(/[^\/]+\/\.\./)
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2012 the Dart project authors<br>
      Licensed under the BSD 3-Clause "New" or "Revised" License.
    HTML

    version '2' do
      self.release = '2.18.5'
      self.base_url = "https://api.dart.dev/stable/#{release}/"
    end

    version '1' do
      self.release = '1.24.3'
      self.base_url = "https://api.dart.dev/stable/#{release}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://api.dart.dev/', opts)
      label = doc.at_css('footer > span').content.strip
      label.sub(/Dart\s*/, '')
    end

    private

    def archive_url
      "https://storage.googleapis.com/dart-archive/channels/stable/release/#{self.class.release}/api-docs/dartdocs-gen-api.zip"
    end

    def download_source
      require 'unix_utils'

      instrument 'info.doc', msg: %(Downloading #{archive_url}...)
      archive = UnixUtils.curl(archive_url)

      instrument 'info.doc', msg: %(Extracting the documentation files to "#{source_directory}"...)
      directory = UnixUtils.unzip(archive)

      FileUtils.mkpath(File.dirname(source_directory))
      # The archive expands to a single directory holding the generated API docs.
      FileUtils.mv(File.join(directory, 'gen-dartdocs'), source_directory)
    ensure
      FileUtils.rm_f(archive) if archive
      FileUtils.rm_rf(directory) if directory
    end
  end
end
