module Docs
  class Php < FileScraper
    self.name = 'PHP'
    self.type = 'php'
    self.version = 'up to 5.6.6'
    self.base_url = 'http://www.php.net/manual/en/'
    self.root_path = 'index.html'
    self.initial_paths = %w(
      funcref.html
      refs.database.html
      set.mysqlinfo.html
      language.control-structures.html
      reserved.exceptions.html
      reserved.interfaces.html
      reserved.variables.html)

    # Downloaded from php.net/download-docs.php
    self.dir = '/Users/Thibaut/DevDocs/Docs/PHP'

    html_filters.push 'php/internal_urls', 'php/entries', 'php/clean_html', 'title'
    text_filters.push 'php/fix_urls'

    options[:title] = false
    options[:root_title] = 'PHP: Hypertext Preprocessor'
    options[:skip_links] = ->(filter) { !filter.initial_page? }

    options[:only_patterns] = [
      /\Aclass\./,
      /\Afunction\./,
      /\Acontrol-structures/,
      /\Areserved\.exceptions/,
      /\Areserved\.interfaces/,
      /\Areserved\.variables/]

    BOOKS = %w(apache apc array bc bzip2 calendar classobj ctype curl datetime
      dba dir dom eio errorfunc event exec fileinfo filesystem filter ftp funchand
      gearman geoip gettext gmagick hash http iconv iisfunc image imagick imap
      info inotify intl json ldap libevent libxml mail mailparse math mbstring
      mcrypt memcached misc mysqli network oauth openssl outcontrol password
      pcre pdo pgsql posix pthreads regex runkit reflection session
      session-pgsql simplexml soap sockets solr sphinx spl spl-types sqlite3
      sqlsrv ssh2 stats stream strings taint tidy uodbc url var varnish xml
      xmlreader xmlrpc xmlwriter xsl yaf yaml zip zlib)

    options[:only] = BOOKS.map { |s| "book.#{s}.html" }

    options[:skip] = %w(
      control-structures.intro.html
      control-structures.alternative-syntax.html
      function.mssql-select-db.html)

    options[:skip_patterns] = [/mysqlnd/]

    options[:attribution] = <<-HTML
      &copy; 1997&ndash;2015 The PHP Documentation Group<br>
      Licensed under the Creative Commons Attribution License v3.0 or later.
    HTML
  end
end
