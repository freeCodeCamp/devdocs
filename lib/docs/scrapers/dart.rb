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

    version '3' do
      self.release = '3.13.2'
      self.base_url = "https://api.dart.dev/stable/#{release}/"

      # dartdoc now serves each library from its directory index, leaving a
      # redirect behind at the old location:
      #   dart-io/dart-io-library.html > dart-io/index.html
      #   dart-io/                     > dart-io/index.html
      options[:fix_urls] = ->(url) do
        url.sub!(%r{/(dart-[^/]+)/(?:\1-library\.html)?(?=#|\z)}, '/\1/index.html')
        url
      end
    end

    version '2' do
      self.release = '2.19.6'
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
      # The archive expands to a single directory holding the generated API docs.
      download_and_extract(archive_url, 'gen-dartdocs')
    end
  end
end
