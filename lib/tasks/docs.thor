class DocsCLI < Thor
  include Thor::Actions

  def self.to_s
    'Docs'
  end

  def initialize(*args)
    require 'docs'
    trap('INT') { puts; exit! } # hide backtrace on ^C
    super
  end

  desc 'list', 'List available documentations'
  def list
    max_length = 0
    Docs.all.
      map  { |doc| [doc.to_s.demodulize.underscore, doc] }.
      each { |pair| max_length = pair.first.length if pair.first.length > max_length }.
      each { |pair| puts "#{pair.first.rjust max_length + 1}: #{pair.second.base_url.remove %r{\Ahttps?://}}" }
  end

  desc 'page <doc> [path] [--verbose] [--debug]', 'Generate a page (no indexing)'
  option :verbose, type: :boolean
  option :debug, type: :boolean
  def page(name, path = '')
    unless path.empty? || path.start_with?('/')
      return puts 'ERROR: [path] must be an absolute path.'
    end

    Docs.install_report :store if options[:verbose]
    if options[:debug]
      GC.disable
      Docs.install_report :filter, :request
    end

    if Docs.generate_page(name, path)
      puts 'Done'
    else
      puts "Failed!#{' (try running with --debug for more information)' unless options[:debug]}"
    end
  rescue Docs::DocNotFound
    invalid_doc(name)
  end

  desc 'generate <doc> [--verbose] [--debug] [--force]', 'Generate a documentation'
  option :verbose, type: :boolean
  option :debug, type: :boolean
  option :force, type: :boolean
  def generate(name)
    Docs.install_report :store if options[:verbose]
    Docs.install_report :scraper if options[:debug]
    Docs.install_report :progress_bar if $stdout.tty?

    unless options[:force]
      puts <<-TEXT.strip_heredoc
        Note: this command will scrape the documentation from the source.
        Some scrapers require a local setup. Others will send thousands of
        HTTP requests, potentially slowing down the source site.
        Please don't use it unless you are modifying the code.

        To download the latest tested version of a documentation, use:
        thor docs:download #{name}\n
      TEXT
      return unless yes? 'Proceed? (y/n)'
    end

    if Docs.generate(name)
      generate_manifest
      puts 'Done'
    else
      puts "Failed!#{' (try running with --debug for more information)' unless options[:debug]}"
    end
  rescue Docs::DocNotFound
    invalid_doc(name)
  end

  desc 'manifest', 'Create the manifest'
  def manifest
    generate_manifest
    puts 'Done'
  end

  desc 'download (<doc> <doc>... | --all)', 'Download documentations'
  option :all, type: :boolean
  def download(*names)
    require 'unix_utils'
    docs = options[:all] ? Docs.all : find_docs(names)
    assert_docs(docs)
    download_docs(docs)
    generate_manifest
    puts 'Done'
  rescue Docs::DocNotFound => error
    invalid_doc(error.name)
  end

  desc 'package (<doc> <doc>... | --all)', 'Package documentations'
  option :all, type: :boolean
  def package(*names)
    require 'unix_utils'
    docs = options[:all] ? Docs.all : find_docs(names)
    assert_docs(docs)
    docs.each(&method(:package_doc))
    puts 'Done'
  rescue Docs::DocNotFound => error
    invalid_doc(error.name)
  end

  desc 'clean', 'Delete documentation packages'
  def clean
    File.delete(*Dir[File.join Docs.store_path, '*.tar.gz'])
    puts 'Done'
  end

  private

  def find_docs(names)
    names.map do |name|
      Docs.find(name)
    end
  end

  def assert_docs(docs)
    if docs.empty?
      puts 'ERROR: called with no arguments.'
      puts 'Run "thor docs:list" for usage patterns.'
      exit
    end
  end

  def invalid_doc(name)
    puts %(ERROR: invalid doc "#{name}".)
    puts 'Run "thor docs:list" to see the list of docs.'
  end

  def download_docs(docs)
    # Don't allow downloaded files to be created as StringIO
    require 'open-uri'
    OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
    OpenURI::Buffer.const_set 'StringMax', 0

    require 'thread'
    length = docs.length
    i = 0

    (1..4).map do
      Thread.new do
        while doc = docs.shift
          status = begin
            download_doc(doc)
            'OK'
          rescue => e
            "FAILED (#{e.class}: #{e.message})"
          end
          puts "(#{i += 1}/#{length}) #{doc.name} #{status}"
        end
      end
    end.map(&:join)
  end

  def download_doc(doc)
    target = File.join(Docs.store_path, "#{doc.path}.tar.gz")
    open "http://dl.devdocs.io/#{doc.path}.tar.gz" do |file|
      FileUtils.mkpath(Docs.store_path)
      FileUtils.mv(file, target)
      unpackage_doc(doc)
    end
  end

  def unpackage_doc(doc)
    path = File.join(Docs.store_path, doc.path)
    FileUtils.mkpath(path)
    tar = UnixUtils.gunzip("#{path}.tar.gz")
    dir = UnixUtils.untar(tar)
    FileUtils.rm_rf(path)
    FileUtils.mv(dir, path)
    FileUtils.rm(tar)
    FileUtils.rm("#{path}.tar.gz")
  end

  def package_doc(doc)
    path = File.join Docs.store_path, doc.path

    if File.exist?(path)
      tar = UnixUtils.tar(path)
      gzip = UnixUtils.gzip(tar)
      FileUtils.mv(gzip, "#{path}.tar.gz")
      FileUtils.rm(tar)
    else
      puts %(ERROR: can't find "#{doc.name}" documentation files.)
    end
  end

  def generate_manifest
    Docs.generate_manifest
  end
end
