module Docs
  class Openjdk < FileScraper
    # Downloaded from packages.debian.org/sid/openjdk-8-doc
    # Extracting subdirectory /usr/share/doc/openjdk-8-jre-headless/api
    self.name = 'OpenJDK'
    self.type = 'openjdk'
    self.root_path = 'overview-summary.html'

    html_filters.insert_after 'internal_urls', 'openjdk/clean_urls'
    html_filters.push 'openjdk/entries', 'openjdk/clean_html'

    options[:skip_patterns] = [
      /compact[123]-/,
      /package-frame\.html/,
      /package-tree\.html/,
      /package-use\.html/,
      /class-use\//,
      /doc-files\//]

    options[:attribution] = <<-HTML
      &copy; 1993&ndash;2017, Oracle and/or its affiliates. All rights reserved.<br>
      Documentation extracted from Debian's OpenJDK Development Kit package.<br>
      Licensed under the GNU General Public License, version 2, with the Classpath Exception.<br>
      Various third party code in OpenJDK is licensed under different licenses (see Debian package).<br>
      Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
    HTML

    version '8' do
      self.release = '8u272'
      self.base_url = 'https://docs.oracle.com/javase/8/docs/api/'
      options[:only_patterns] = [/\A(java|javax|org)\//]
    end

    # Monkey patch to properly read HTML files encoded in ISO-8859-1
    def read_file(path)
      File.read(path).force_encoding('iso-8859-1').encode('utf-8') rescue nil
    end

    def get_latest_version(opts)
      latest_version = 8
      current_attempt = latest_version
      attempts = 0

      while attempts < 3
        current_attempt += 1

        doc = fetch_doc("https://packages.debian.org/sid/openjdk-#{current_attempt}-doc", opts)
        if doc.at_css('.perror').nil?
          latest_version = current_attempt
          attempts = 0
        else
          attempts += 1
        end
      end

      latest_version
    end
  end
end
