module Docs
  class Ruby < Rdoc
    # Generated with:
    # find \
    #   *.c \
    #   lib \
    #   ext/bigdecimal \
    #   ext/date \
    #   ext/digest \
    #   ext/json \
    #   ext/pathname \
    #   ext/psych \
    #   ext/readline \
    #   ext/ripper \
    #   ext/socket \
    #   ext/stringio \
    #   ext/zlib \
    #   \( -name '*.c' -or -name '*.rb' \) \
    #   -not -wholename '*sample/*' \
    # | xargs \
    #   rdoc --format=darkfish --no-line-numbers --op=rdoc --visibility=public

    self.version = '2.1.2'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Ruby'

    html_filters.replace 'rdoc/entries', 'ruby/entries'

    options[:root_title] = 'Ruby Programming Language'

    options[:skip] += %w(
      fatal.html
      CompositePublisher.html
      Data.html
      E2MM.html
      English.html
      GServer.html
      MakeMakefile.html
      ParallelEach.html
      SshDirPublisher.html
      SshFilePublisher.html
      SshFreshDirPublisher.html
      YAML/DBM.html)

    options[:skip_patterns] = [
      /\AComplex/,
      /\AException2MessageMapper/,
      /\AJSON\/Ext/,
      /\AGem/,
      /\AHTTP/i,
      /\AIRB/,
      /\AMiniTest/i,
      /\ANet\/(?!HTTP)/,
      /\ANQXML/,
      /\AOpenSSL/,
      /\AOptionParser\//,
      /\APride/,
      /\APsych\//,
      /\ARacc/,
      /\ARake/,
      /\ARbConfig/,
      /\ARDoc/,
      /\AREXML/,
      /\ARSS/,
      /\AShell\//,
      /\ASocket\//,
      /\ATest/,
      /\AWEBrick/,
      /\AXML/,
      /\AXMP/]

    options[:attribution] = <<-HTML
      Ruby Core &copy; 1993&ndash;2014 Yukihiro Matsumoto<br>
      Licensed under the Ruby License.<br>
      Ruby Standard Library &copy; contributors<br>
      Licensed under their own licenses.
    HTML
  end
end
