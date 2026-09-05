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
    load 'tasks/sprites.thor'
    invoke 'sprites:generate', [], :remove_public_icons => true, :verbose => options[:verbose]

    manifest.compile App.assets_compile
    manifest.clean(options[:keep]) if options[:clean]
  end

  desc 'clean [--keep=<n>] [--verbose]', 'Clean old assets'
  option :keep, type: :numeric, default: 0, desc: 'Number of old assets to keep'
  option :verbose, type: :boolean
  def clean
    manifest.clean(options[:keep])
  end

  # Render the dynamic shells and the news feed to static files so the app can
  # be served without the Ruby process. Rendered through the real Rack app so
  # the output is identical to what Sinatra serves. Must run after `compile`.
  desc 'render_static', 'Render index.html, service-worker.js and feed.atom to public/'
  def render_static
    require 'rack'

    # The app booted (in `initialize`) before `compile` wrote the asset
    # manifest, so point the asset helpers at the freshly compiled manifest.
    Sprockets::Helpers.configure do |config|
      config.manifest = Sprockets::Manifest.new(nil, App.assets_manifest_path)
    end

    origin = ENV['DEPLOY_HOST'] || 'devdocs.io'

    {
      '/'                  => 'index.html',
      '/service-worker.js' => 'service-worker.js',
      '/feed'              => 'feed.atom',
    }.each do |path, filename|
      env = Rack::MockRequest.env_for("https://#{origin}#{path}")
      status, _headers, body = App.call(env)
      raise "Failed to render #{path} (status #{status})" unless status == 200

      content = +''
      body.each { |part| content << part }
      body.close if body.respond_to?(:close)

      File.write(File.join(App.public_folder, filename), content)
      logger.info("Rendered #{path} -> public/#{filename}")
    end
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
