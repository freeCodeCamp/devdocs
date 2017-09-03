module Docs
  class Openjdk < FileScraper
    self.name = 'OpenJDK'
    self.type = 'openjdk'
    self.root_path = 'overview-summary.html'
    # Downloaded from packages.debian.org/sid/openjdk-8-doc
    # Extracting subdirectory /usr/share/doc/openjdk-8-jre-headless/api
    self.dir = '/Users/Thibaut/DevDocs/Docs/OpenJDK'

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
      self.release = '8'

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
        /\Ajavax\/tools\//]
    end

    version '8 GUI' do
      self.release = '8'

      options[:only_patterns] = [
        /\Ajava\/awt\//,
        /\Ajavax\/swing\//]
    end

    version '8 Web' do
      self.release = '8'

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
  end
end
