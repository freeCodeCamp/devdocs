module Docs
  class Ruby < Rdoc
    # Generated with:
    # rdoc \
    #   --root . \
    #   --page-dir doc \
    #   --encoding=UTF-8 \
    #   --visibility=public \
    #   --format=darkfish \
    #   --no-line-numbers \
    #   --op html .

    self.version = '2.2.0'
    self.dir = '/Users/Thibaut/DevDocs/Docs/RDoc/Ruby'

    html_filters.replace 'rdoc/entries', 'ruby/entries'

    options[:root_title] = 'Ruby Programming Language'
    options[:title] = ->(filter) { filter.slug == 'globals_rdoc' ? 'Globals' : false }

    options[:skip] += %w(
      contributing_rdoc.html
      contributors_rdoc.html
      dtrace_probes_rdoc.html
      maintainers_rdoc.html
      regexp_rdoc.html
      standard_library_rdoc.html
      syntax_rdoc.html
      Data.html
      English.html
      Fcntl.html
      Kconv.html
      NKF.html
      OLEProperty.html
      OptParse.html
      UnicodeNormalize.html)

    options[:skip_patterns] += [
      /\Alib\//,
      /\ADEBUGGER__/,
      /\AException2MessageMapper/,
      /\AJSON\/Ext/,
      /\AGem/,
      /\AHTTP/i,
      /\AIRB/,
      /\AMakeMakefile/i,
      /\ANQXML/,
      /\AOptionParser\//,
      /\APrettyPrint/,
      /\APride/,
      /\AProfiler__/,
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
      /win32/i,
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
