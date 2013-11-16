module Docs
  class Ruby < Rdoc
    # Generated with:
    # rdoc \
    #   --format=darkfish \
    #   --no-line-numbers \
    #   --op=rdoc \
    #   --visibility=public \
    #   *.c \
    #   lib/**/*.rb \
    #   lib/*.rb \
    #   ext/bigdecimal/*.c \
    #   ext/bigdecimal/lib/*.rb \
    #   ext/bigdecimal/lib/**/*.rb \
    #   ext/date/*.c \
    #   ext/date/lib/*.rb \
    #   ext/date/lib/**/*.rb \
    #   ext/digest/*.c \
    #   ext/digest/**/*.c \
    #   ext/digest/**/*.rb \
    #   ext/json/lib/**/*.rb \
    #   ext/pathname/*.c \
    #   ext/pathname/lib/*.rb \
    #   ext/psych/*.c \
    #   ext/psych/lib/*.rb \
    #   ext/psych/lib/**/*.rb \
    #   ext/readline/*.c \
    #   ext/ripper/*.c \
    #   ext/ripper/lib/*.rb \
    #   ext/ripper/lib/**/*.rb \
    #   ext/socket/*.c \
    #   ext/socket/lib/*.rb \
    #   ext/socket/lib/**/*.rb \
    #   ext/stringio/*.c \
    #   ext/zlib/*.c

    self.version = '2.0.0'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Ruby'

    html_filters.replace 'rdoc/entries', 'ruby/entries'

    options[:root_title] = 'Ruby Programming Language'

    options[:skip] += %w(
      fatal.html
      unknown.html
      Data.html
      E2MM.html
      English.html
      Exception2MessageMapper.html
      GServer.html
      MakeMakefile.html
      ParallelEach.html
      Requirement.html
      YAML/DBM.html)

    options[:skip_patterns] = [
      /\AComplex/,
      /\AGem/,
      /\AHttpServer/,
      /\AIRB/,
      /\AMiniTest/i,
      /\ANQXML/,
      /\AOpenSSL/,
      /\APride/,
      /\ARacc/,
      /\ARake/,
      /\ARbConfig/,
      /\ARDoc/,
      /\AREXML/,
      /\ARSS/,
      /\ATest/,
      /\AWEBrick/,
      /\AXML/,
      /\AXMP/
    ]

    options[:attribution] = <<-HTML
      Ruby Core &copy; 1993&ndash;2013 Yukihiro Matsumoto<br>
      Licensed under the Ruby License.<br>
      Ruby Standard Library &copy; contributors<br>
      Licensed under their own licenses.
    HTML
  end
end
