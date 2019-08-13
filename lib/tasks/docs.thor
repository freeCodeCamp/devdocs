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
  option :packaged, type: :boolean
  def list
    if options[:packaged]
      slugs = Dir[File.join(Docs.store_path, '*.tar.gz')].map { |f| File.basename(f, '.tar.gz') }
      names = find_docs_by_slugs(slugs).map do |doc|
        name = if doc.version?
          "#{doc.superclass.to_s.demodulize.underscore}@#{doc.version}"
        else
          doc.to_s.demodulize.underscore
        end
      end
    else
      names = Docs.all.flat_map do |doc|
        name = doc.to_s.demodulize.underscore
        if doc.versioned?
          doc.versions.map { |_doc| "#{name}@#{_doc.version}" }
        else
          name
        end
      end
    end

    output = names.join("\n")

    require 'tty-pager'
    TTY::Pager.new.page(output)
  end

  desc 'page <doc> [path] [--version] [--verbose] [--debug]', 'Generate a page (no indexing)'
  option :version, type: :string
  option :verbose, type: :boolean
  option :debug, type: :boolean
  def page(name, path = '')
    unless path.empty? || path.start_with?('/')
      return puts 'ERROR: [path] must be an absolute path.'
    end

    Docs.install_report :image
    Docs.install_report :store if options[:verbose]
    if options[:debug]
      GC.disable
      Docs.install_report :filter, :request, :doc
    end

    if Docs.generate_page(name, options[:version], path)
      puts 'Done'
    else
      puts "Failed!#{' (try running with --debug for more information)' unless options[:debug]}"
    end
  rescue Docs::DocNotFound => error
    handle_doc_not_found_error(error)
  end

  desc 'generate <doc> [--version] [--verbose] [--debug] [--force] [--package]', 'Generate a documentation'
  option :version, type: :string
  option :all, type: :boolean
  option :verbose, type: :boolean
  option :debug, type: :boolean
  option :force, type: :boolean
  option :package, type: :boolean
  def generate(name)
    Docs.rescue_errors = true
    Docs.install_report :store if options[:verbose]
    Docs.install_report :scraper if options[:debug]
    Docs.install_report :progress_bar, :doc, :image, :requester if $stdout.tty?

    require 'unix_utils' if options[:package]

    doc = Docs.find(name, options[:version])

    if doc < Docs::UrlScraper && !options[:force]
      puts <<-TEXT.strip_heredoc
        /!\\ WARNING /!\\

        Some scrapers send thousands of HTTP requests in a short period of time,
        which can slow down the source site and trouble its maintainers.

        Please scrape responsibly. Don't do it unless you're modifying the code.

        To download the latest tested version of this documentation, run:
          thor docs:download #{name}\n
      TEXT
      return unless yes? 'Proceed? (y/n)'
    end

    result = if doc.version && options[:all]
      doc.superclass.versions.all? do |_doc|
        puts "==> #{_doc.version}"
        generate_doc(_doc, package: options[:package]).tap { puts "\n" }
      end
    else
      generate_doc(doc, package: options[:package])
    end

    generate_manifest if result
  rescue Docs::DocNotFound => error
    handle_doc_not_found_error(error)
  ensure
    Docs.rescue_errors = false
  end

  desc 'manifest', 'Create the manifest'
  def manifest
    generate_manifest
    puts 'Done'
  end

  desc 'download (<doc> <doc@version>... | --default | --installed)', 'Download documentations'
  option :default, type: :boolean
  option :installed, type: :boolean
  option :all, type: :boolean
  def download(*names)
    require 'unix_utils'
    docs = if options[:default]
      Docs.defaults
    elsif options[:installed]
      Docs.installed
    elsif options[:all]
      Docs.all_versions
    else
      find_docs(names)
    end
    assert_docs(docs)
    download_docs(docs)
    generate_manifest
    puts 'Done'
  rescue Docs::DocNotFound => error
    handle_doc_not_found_error(error)
  end

  desc 'package <doc> <doc@version>...', 'Package documentations'
  def package(*names)
    require 'unix_utils'
    docs = find_docs(names)
    assert_docs(docs)
    docs.each(&method(:package_doc))
    puts 'Done'
  rescue Docs::DocNotFound => error
    handle_doc_not_found_error(error)
  end

  desc 'clean', 'Delete documentation packages'
  def clean
    File.delete(*Dir[File.join Docs.store_path, '*.tar.gz'])
    puts 'Done'
  end

  desc 'upload', '[private]'
  option :dryrun, type: :boolean
  option :packaged, type: :boolean
  def upload(*names)
    require 'net/sftp'

    if options[:packaged]
      slugs = Dir[File.join(Docs.store_path, '*.tar.gz')].map { |f| File.basename(f, '.tar.gz') }
      docs = find_docs_by_slugs(slugs)
    else
      docs = find_docs(names)
    end

    assert_docs(docs)

    # Verify files are present
    docs.each do |doc|
      unless Dir.exists?(File.join(Docs.store_path, doc.path))
        puts "ERROR: directory #{File.join(Docs.store_path, doc.path)} not found."
        return
      end

      unless File.exists?(File.join(Docs.store_path, "#{doc.path}.tar.gz"))
        puts "ERROR: package for '#{doc.slug}' documentation not found. Run 'thor docs:package #{doc.slug}' to create it."
        return
      end
    end

    # Sync files with S3 (used by the web app)
    puts '[S3] Begin syncing.'
    docs.each do |doc|
      puts "[S3] Syncing #{doc.path}..."
      cmd = "aws s3 sync #{File.join(Docs.store_path, doc.path)} s3://devdocs-assets/#{doc.path} --delete --profile devdocs"
      cmd << ' --dryrun' if options[:dryrun]
      system(cmd)
    end
    puts '[S3] Done syncing.'

    # Upload packages to dl.devdocs.io (used by the "thor docs:download" command)
    puts '[MaxCDN] Begin uploading.'
    Net::SFTP.start('ftp.devdocs-dl.devdocs.netdna-cdn.com', ENV['DEVDOCS_DL_USERNAME'], password: ENV['DEVDOCS_DL_PASSWORD']) do |sftp|
      docs.each do |doc|
        filename = "#{doc.path}.tar.gz"
        print "[MaxCDN] Uploading #{filename}..."
        if options[:dryrun]
          print "\n"
        else
          sftp.upload! File.join(Docs.store_path, filename), File.join('', 'public_html', filename)
          print " OK\n"
        end
      end
    end
    puts '[MaxCDN] Done uploading.'
  end

  desc 'commit', '[private]'
  option :message, type: :string
  option :amend, type: :boolean
  def commit(name)
    doc = Docs.find(name, false)
    message = options[:message] || "Update #{doc.name} documentation (#{doc.versions.first.release})"
    amend = " --amend" if options[:amend]
    system("git add assets/ *#{name}*") && system("git commit -m '#{message}'#{amend}")
  rescue Docs::DocNotFound => error
    handle_doc_not_found_error(error)
  end

  desc 'prepare_deploy', 'Internal task executed before deployment'
  def prepare_deploy
    puts 'Docs -- BEGIN'

    require 'open-uri'
    require 'thread'

    docs = Docs.all_versions
    time = Time.now.to_i
    mutex = Mutex.new

    (1..6).map do
      Thread.new do
        while doc = docs.shift
          dir = File.join(Docs.store_path, doc.path)
          FileUtils.mkpath(dir)

          ['index.json', 'meta.json'].each do |filename|
            open("https://docs.devdocs.io/#{doc.path}/#{filename}?#{time}") do |file|
              mutex.synchronize do
                path = File.join(dir, filename)
                File.write(path, file.read)
              end
            end
          end

          puts "Docs -- Downloaded #{doc.slug}"
        end
      end
    end.map(&:join)

    puts 'Docs -- Generating manifest...'
    generate_manifest

    puts 'Docs -- DONE'
  end

  private

  def find_docs(names)
    names.flat_map do |name|
      name, version = name.split(/@|~/)
      if version == 'all'
        Docs.find(name, false).versions
      else
        Docs.find(name, version)
      end
    end
  end

  def find_docs_by_slugs(slugs)
    slugs.flat_map do |slug|
      slug, version = slug.split(/~/)
      Docs.find_by_slug(slug, version)
    end
  end

  def assert_docs(docs)
    if docs.empty?
      puts 'ERROR: called with no arguments.'
      puts 'Run "thor list" for usage patterns.'
      exit
    end
  end

  def handle_doc_not_found_error(error)
    puts %(ERROR: #{error}.)
    puts 'Run "thor docs:list" to see the list of docs and versions.'
  end

  def generate_doc(doc, package: nil)
    if Docs.generate(doc)
      package_doc(doc) if package
      puts 'Done'
      true
    else
      puts "Failed!#{' (try running with --debug for more information)' unless options[:debug]}"
      false
    end
  end

  def download_docs(docs)
    # Don't allow downloaded files to be created as StringIO
    require 'open-uri'
    OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
    OpenURI::Buffer.const_set 'StringMax', 0

    require 'thread'
    length = docs.length
    mutex = Mutex.new
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
          mutex.synchronize { puts "(#{i += 1}/#{length}) #{doc.name}#{ " #{doc.version}" if doc.version} #{status}" }
        end
      end
    end.map(&:join)
  end

  def download_doc(doc)
    target_path = File.join(Docs.store_path, doc.path)
    open "http://dl.devdocs.io/#{doc.path}.tar.gz" do |file|
      FileUtils.mkpath(target_path)
      file.close
      tar = UnixUtils.gunzip(file.path)
      dir = UnixUtils.untar(tar)
      FileUtils.rm_rf(target_path)
      FileUtils.mv(dir, target_path)
      FileUtils.rm(file.path)
    end
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
