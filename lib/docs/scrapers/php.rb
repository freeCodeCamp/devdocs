module Docs
  class Php < FileScraper
    # WARNING: if you are the kind of developer who likes to automate things,
    # this scraper will hurt your feelings.

    self.name = 'PHP'
    self.type = 'php'
    self.version = 'up to 5.5.6'
    self.base_url = 'http://www.php.net/manual/en/'
    self.root_path = 'extensions.alphabetical.html'

    # Downloaded from php.net/download-docs.php
    self.dir = '/Users/Thibaut/DevDocs/Docs/PHP'

    html_filters.push 'php/entries', 'php/clean_html', 'title'
    text_filters.push 'php/fix_urls'

    options[:title] = false
    options[:root_title] = 'PHP: Hypertext Preprocessor'

    options[:only] = [] # using a whitelist

    options[:only_patterns] = [/\Afunction\.\w+\.html\z/,
      /\Areserved\.exceptions/, /\Areserved\.interfaces/,
      /\Areserved\.variables/, /\Acontrol\-structures/]

    # TODO: MongoDB, Phar
    BOOKS = %w(amqp apache apc array bc bzip2 calendar classkit classobj com
      ctype curl datetime dba dir dom eio errorfunc exec fileinfo filesystem
      filter ftp funchand gearman geoip gettext gmagick hash http iconv iisfunc
      image imagick imap info inotify intl json ldap libevent libxml mail
      mailparse math mbstring mcrypt memcached misc mysqli network oauth
      openssl outcontrol password pcre pdo pgsql posix pthreads quickhash
      readline regex runkit reflection session session-pgsql simplexml soap
      sockets solr sphinx spl spl-types sqlite3 sqlsrv ssh2 stats stream
      strings taint tidy url v8js var varnish weakref xml xmlreader xmlrpc
      xmlwriter xsl yaf yaml zip zlib uodbc)
    options[:only].concat BOOKS.map { |s| "book.#{s}.html" }
    options[:only_patterns].concat BOOKS.map { |s| /\Afunction\.#{s}(?:\.|\-)/ }

    CLASSES = %w(apciterator curlfile dateinterval dateperiod collator
      numberformatter locale normalizer messageformatter resourcebundle
      spoofchecker transliterator uconverter memcached thread worker stackable
      mutex cond runkit reflector sessionhandler sessionhandlerinterface
      sphinxclient countable arrayobject streamwrapper xmlreader xsltprocessor
      ziparchive exception errorexception)
    options[:only].concat CLASSES.map { |s| "class.#{s}.html" }
    options[:only_patterns].concat CLASSES.map { |s| /\A#{s}\./ }

    FUNCTION_PREFIXES = %w(assert base base64 cal call chunk class cli
      connection convert count create date debug define disk dns easter ereg
      eregi error event file finfo forward func gc gd get grapheme halt header
      headers highlight html http idn iis in inet ini is iterator magic mb md5
      mdecrypt memory mime move mt nl ob output parse pg php preg print proc
      quoted realpath register restore set sha1 shell show stream socket spl
      str sys tidy time timezone unregister use utf8 variant xml)
    options[:only_patterns].concat FUNCTION_PREFIXES.map { |s| /\Afunction\.#{s}\-/ }

    FUNCTIONS = %w(trigger-error user-error require-once include-once)
    options[:only].concat FUNCTIONS.map { |s| "function.#{s}.html" }

    options[:only_patterns].concat [
      /function\.\w+\-exists\.html\z/,
      /\A\w+iterator\./,
      /\Afunction\.bz\w+\.html\z/,
      /\Aclass\.\w+iterator\.html\z/,
      /\Aclass\.\w+exception\.html\z/,
      /\Aclass\.amqp/, /\Aamqp/,
      /\Aclass\.datetime/, /\Adatetime/,
      /\Aclass\.dom/, /\Adom/,
      /\Aclass\.gearman/, /\Agearman/,
      /\Aclass\.gmagick/, /\Agmagick/,
      /\Aclass\.http/, /\Ahttp/,
      /\Aclass\.imagick/, /\Aimagick/,
      /\Aclass\.intl/, /\Aintl/,
      /\Aclass\.json/, /\Ajson/,
      /\Aclass\.mysqli/, /\Amysqli/,
      /\Aclass\.oauth/, /\Aoauth/,
      /\Aclass\.pdo/, /\Apdo/,
      /\Aclass\.quickhash/, /\Aquickhash/,
      /\Aclass\.reflection/, /\Areflection/,
      /\Aclass\.simplexml/, /\Asimplexml/,
      /\Aclass\.soap/, /\Asoap/,
      /\Aclass\.solr/, /\Asolr/,
      /\Aclass\.spl/, /\Aspl/,
      /\Aclass\.sqlite3/, /\Asqlite3/,
      /\Aclass\.tidy/, /\Atidy/,
      /\Aclass\.v8js/, /\Av8js/,
      /\Aclass\.varnish/, /\Avarnish/,
      /\Aclass\.weak/, /\Aweak/,
      /\Aclass\.yaf\-/, /\Ayaf\-/]

    options[:skip_patterns] = [/example/, /quickstart/, /\.setup\.html\z/,
      /\.overview\.html\z/, /\.requirements\.html\z/, /\.installation\.html\z/,
      /\.install\.html\z/, /\.configuration\.html\z/, /\.resources\.html\z/,
      /\.constants\.html\z/, /\Amysqlinfo/, /\Adatetime\.formats/]

    options[:skip] = %w(control-structures.intro.html
      control-structures.alternative-syntax.html memcached.expiration.html
      memcached.callbacks.html memcached.callbacks.result.html
      memcached.callbacks.read-through.html memcached.sessions.html
      mysqli.persistconns.html mysqli.notes.html mysqli.summary.html
      pdo.connections.html pdo.transactions.html pdo.prepared-statements.html
      pdo.error-handling.html pdo.lobs.htm pdo.drivers.html
      reflection.extending.html http.request.options.html
      class.lapackexception.html class.snmpexception.html function.mhash.html
      spl.datastructures.html spl.iterators.html spl.interfaces.html
      spl.exceptions.html spl.files.html spl.misc.html)

    options[:attribution] = <<-HTML
      &copy; 1997&ndash;2013 The PHP Documentation Group<br>
      Licensed under the Creative Commons Attribution License v3.0 or later.
    HTML
  end
end
