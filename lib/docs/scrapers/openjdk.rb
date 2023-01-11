module Docs
  class Openjdk < FileScraper

    self.name = 'OpenJDK'
    self.type = 'openjdk'
    self.root_path = 'overview-summary.html'
    self.links = {
      home: 'https://openjdk.java.net/',
      code: 'https://github.com/openjdk/jdk'
    }

    html_filters.insert_after 'internal_urls', 'openjdk/clean_urls'

    options[:skip_patterns] = [
      /compact[123]-/,
      /package-frame\.html/,
      /package-tree\.html/,
      /package-use\.html/,
      /class-use\//,
      /doc-files\//,
      /\.svg/,
      /\.png/
    ]

    options[:only_patterns] = [
      /\Ajava\./,
      /\Ajdk\./
    ]

    options[:attribution] = <<-HTML
      &copy; 1993, 2022, Oracle and/or its affiliates. All rights reserved.<br>
      Documentation extracted from Debian's OpenJDK Development Kit package.<br>
      Licensed under the GNU General Public License, version 2, with the Classpath Exception.<br>
      Various third party code in OpenJDK is licensed under different licenses (see Debian package).<br>
      Java and OpenJDK are trademarks or registered trademarks of Oracle and/or its affiliates.
    HTML

    NEWFILTERS = ['openjdk/entries_new', 'openjdk/clean_html_new']

    version '19' do
      self.release = '19'
      self.root_path = 'index.html'
      self.base_url = 'https://docs.oracle.com/en/java/javase/19/docs/api/'

      html_filters.push NEWFILTERS

      options[:container] = 'main'
    end

    version '18' do
      self.release = '18'
      self.root_path = 'index.html'
      self.base_url = 'https://docs.oracle.com/en/java/javase/18/docs/api/'

      html_filters.push NEWFILTERS

      options[:container] = 'main'
    end

    version '17' do
      self.release = '17'
      self.root_path = 'index.html'
      self.base_url = 'https://docs.oracle.com/en/java/javase/17/docs/api/'

      html_filters.push NEWFILTERS

      options[:container] = 'main'
    end

    OLDFILTERS = ['openjdk/entries', 'openjdk/clean_html']

    version '11' do
      self.release = '11.0.11'
      self.root_path = 'index.html'
      self.base_url = 'https://docs.oracle.com/en/java/javase/11/docs/api/'

      html_filters.push OLDFILTERS
    end

    version '8' do
      self.release = '8'
      self.base_url = 'https://docs.oracle.com/javase/8/docs/api/'

      html_filters.push OLDFILTERS

      options[:only_patterns] = [
        /\Ajava\/beans\//,
        /\Ajava\/io\//,
        /\Ajava\/lang\//,
        /\Ajava\/math\//,
        /\Ajava\/net\//,
        /\Ajava\/nio\//,
        /\Ajava\/security\//,
        /\Ajava\/text\//,
        /\Ajava\/time\//,
        /\Ajava\/util\//,
        /\Ajavax\/annotation\//,
        /\Ajavax\/crypto\//,
        /\Ajavax\/imageio\//,
        /\Ajavax\/lang\//,
        /\Ajavax\/management\//,
        /\Ajavax\/naming\//,
        /\Ajavax\/net\//,
        /\Ajavax\/print\//,
        /\Ajavax\/script\//,
        /\Ajavax\/security\//,
        /\Ajavax\/sound\//,
        /\Ajavax\/tools\//
      ]
    end

    version '8 GUI' do
      self.release = '8'
      self.base_url = 'https://docs.oracle.com/javase/8/docs/api/'

      html_filters.push OLDFILTERS

      options[:only_patterns] = [
        /\Ajava\/awt\//,
        /\Ajavax\/swing\//
      ]

    end

    version '8 Web' do
      self.release = '8'
      self.base_url = 'https://docs.oracle.com/javase/8/docs/api/'

      html_filters.push OLDFILTERS

      options[:only_patterns] = [
        /\Ajava\/applet\//,
        /\Ajava\/rmi\//,
        /\Ajava\/sql\//,
        /\Ajavax\/accessibility\//,
        /\Ajavax\/activation\//,
        /\Ajavax\/activity\//,
        /\Ajavax\/jws\//,
        /\Ajavax\/rmi\//,
        /\Ajavax\/sql\//,
        /\Ajavax\/transaction\//,
        /\Ajavax\/xml\//,
        /\Aorg\/ietf\//,
        /\Aorg\/omg\//,
        /\Aorg\/w3c\//,
        /\Aorg\/xml\//]
    end

    # Monkey patch to properly read HTML files encoded in ISO-8859-1
    def read_file(path)
      File.read(path).force_encoding('iso-8859-1').encode('utf-8') rescue nil
    end

    def get_latest_version(opts)
      doc = fetch_doc("https://jdk.java.net/archive/", opts)
      version = doc.at_css('#downloads > table > tr > th').content
      version.gsub!(/\(.*\)/, '')
      version.gsub!(/[a-zA-z]/, '')
      version
    end
  end
end
