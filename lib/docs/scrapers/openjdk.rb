module Docs
  class Openjdk < FileScraper
    self.name = 'OpenJDK'
    self.type = 'openjdk'
    self.root_path = 'overview-summary.html'
    self.links = {
      home: 'http://openjdk.java.net/',
      code: 'http://hg.openjdk.java.net/jdk8u'
    }
    self.release = '8'
    # Downloaded from packages.debian.org/sid/openjdk-8-doc
    # extracting subdirectoy /usr/share/doc/openjdk-8-jre-headless/api
    self.dir = '/Users/Thibaut/DevDocs/Docs/Java'

    html_filters.push 'openjdk/entries', 'openjdk/clean_html'
    html_filters.insert_after 'internal_urls', 'openjdk/clean_urls'

    options[:skip_patterns] = [
      /compact[123]-/,
      /package-frame\.html/,
      /package-tree\.html/,
      /package-use\.html/,
      /class-use\//,
      /doc-files\//]

    options[:attribution] = <<-HTML
      &copy; 1993&ndash;2017, Oracle and/or its affiliates. All rights reserved.<br>
      Use is subject to <a href="http://download.oracle.com/otndocs/jcp/java_se-8-mrel-spec/license.html">license terms</a>.<br>
      We are not endorsed by or affiliated with Oracle.
    HTML

    version 'Core' do
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

    version 'GUI' do
      options[:only_patterns] = [
        /\Ajava\/awt\//,
        /\Ajavax\/swing\//]
    end

    version 'Web' do
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
