module Docs
  class Php < FileScraper
    # Downloaded from php.net/download-docs.php
    include FixInternalUrlsBehavior

    self.name = 'PHP'
    self.type = 'php'
    self.release = '8.2'
    self.base_url = 'https://www.php.net/manual/en/'
    self.root_path = 'index.html'
    self.initial_paths = %w(
      funcref.html
      langref.html
      refs.database.html
      set.mysqlinfo.html
      language.control-structures.html
      reference.pcre.pattern.syntax.html
      reserved.exceptions.html
      reserved.interfaces.html
      reserved.variables.html)

    self.links = {
      home: 'https://www.php.net/',
      code: 'https://git.php.net/?p=php-src.git;a=summary'
    }

    html_filters.push 'php/internal_urls', 'php/entries', 'php/clean_html', 'title'
    text_filters.push 'php/fix_urls'

    options[:title] = false
    options[:root_title] = 'PHP: Hypertext Preprocessor'
    options[:skip_links] = ->(filter) { !filter.initial_page? }

    options[:only_patterns] = [
      /\Alanguage\./,
      /\Aclass\./,
      /\Afunctions?\./,
      /\Acontrol-structures/,
      /\Aregexp\./,
      /\Areserved\.exceptions/,
      /\Areserved\.interfaces/,
      /\Areserved\.variables/]

    BOOKS = %w(apache apc apcu array bc blenc bzip2 calendar csprng  componere classobj ctype curl
      datetime dba dbx dir dio dom ds eio errorfunc enchant ev event exec exif fileinfo filesystem filter
      fdf ftp funchand fpm gearman geoip gettext gmagick gmp gnupg hash ibase iconv iisfunc image
      imagick imap info inotify intl iisfunc json judy ldap libevent libxml lua lzf mail mailparse
      math mhash mbstring mcrypt memcached misc mysqli ncurses network nsapi oauth openssl openal opcache
      outcontrol password parle pcntl phpdbg pcre pdo pgsql phar posix proctitle pspell pthreads quickhash recode regex runkit runkit7 radius rar
      reflection readline sca session sem session-pgsql shmop simplexml ssdeep sdo sdodasrel sdo-das-xml sodium soap sockets solr snmp sphinx spl stomp
      spl-types sqlite3 sqlsrv ssh2 stats stream strings sync svm svn taint tidy tokenizer uodbc url uopz
      v8js var varnish wddx weakref wincache xattr xdiff xhprof xml xmlreader xmlrpc xmlwriter xsl yaf yar yaml yac zip zookeeper zlib)

    options[:only] = BOOKS.map { |s| "book.#{s}.html" }

    options[:skip] = %w(
      control-structures.intro.html
      control-structures.alternative-syntax.html
      function.mssql-select-db.html
      pthreads.modifiers.html)

    options[:skip_patterns] = [/mysqlnd/, /xdevapi/i]

    options[:attribution] = <<-HTML
      &copy; 1997&ndash;2022 The PHP Documentation Group<br>
      Licensed under the Creative Commons Attribution License v3.0 or later.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://www.php.net/supported-versions.php', opts)
      doc.at_css('table > tbody > .stable:last-of-type > td > a').content.strip
    end

  end
end
