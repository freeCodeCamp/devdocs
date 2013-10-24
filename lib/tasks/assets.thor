class AssetsCLI < Thor
  def self.to_s
    'Assets'
  end

  def initialize(*args)
    ENV['RACK_ENV'] = 'production'
    require 'app'
    super
  end

  desc 'compile [--clean] [--keep=<n>] [--verbose]', 'Compile all assets'
  option :clean, type: :boolean, desc: 'Clean old assets after compilation'
  option :keep, type: :numeric, default: 0, desc: 'Number of old assets to keep'
  option :verbose, type: :boolean
  def compile
    manifest.compile App.assets_compile
    manifest.clean(options[:keep]) if options[:clean]
  end

  desc 'clean [--keep=<n>] [--verbose]', 'Clean old assets'
  option :keep, type: :numeric, default: 0, desc: 'Number of old assets to keep'
  option :verbose, type: :boolean
  def clean
    manifest.clean(options[:keep])
  end

  private

  def sprockets
    @sprockets ||= App.sprockets.tap do |sprockets|
      sprockets.logger = logger
      sprockets.cache = nil
    end
  end

  def manifest
    @manifest ||= Sprockets::Manifest.new sprockets.index, App.assets_manifest_path
  end

  def logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.level = options[:verbose] ? Logger::DEBUG : Logger::INFO
      logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    end
  end
end
