module Docs
  class Ruby < Rdoc
    # Instructions:
    #   1. Download Ruby's source code
    #   2. Run "./configure && make html" (in the Ruby directory)
    #   3. Copy the ".ext/html" directory to "docs/ruby~[version]"

    include FixInternalUrlsBehavior

    self.links = {
      home: 'https://www.ruby-lang.org/',
      code: 'https://github.com/ruby/ruby'
    }

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
      extension_rdoc.html
      extension_ja_rdoc.html
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
      /\ATest/,
      /\AWEBrick/,
      /win32/i,
      /\AXML/,
      /\AXMP/]

    options[:attribution] = <<-HTML
      Ruby Core &copy; 1993&ndash;2022 Yukihiro Matsumoto<br>
      Licensed under the Ruby License.<br>
      Ruby Standard Library &copy; contributors<br>
      Licensed under their own licenses.
    HTML

    version '3.2' do
      self.release = '3.2.0'
    end
    
    version '3.1' do
      self.release = '3.1.3'
    end

    version '3' do
      self.release = '3.0.0'
    end

    version '2.7' do
      self.release = '2.7.2'
    end

    version '2.6' do
      self.release = '2.6.3'
    end

    version '2.5' do
      self.release = '2.5.3'
    end

    version '2.4' do
      self.release = '2.4.5'
    end

    version '2.3' do
      self.release = '2.3.8'
    end

    version '2.2' do
      self.release = '2.2.10'
    end

    def get_latest_version(opts)
      tags = get_github_tags('ruby', 'ruby', opts)
      tags.each do |tag|
        version = tag['name'].gsub(/_/, '.')[1..-1]

        if !/^([0-9.]+)$/.match(version).nil? && version.count('.') == 2
          return version
        end
      end

    end
  end
end
