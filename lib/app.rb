require 'bundler/setup'
Bundler.require :app

class App < Sinatra::Application
  Bundler.require environment
  require 'sinatra/cookies'

  Rack::Mime::MIME_TYPES['.webapp'] = 'application/x-web-app-manifest+json'

  configure do
    set :sentry_dsn, ENV['SENTRY_DSN']
    set :protection, except: [:frame_options, :xss_header]

    set :root, Pathname.new(File.expand_path('../..', __FILE__))
    set :sprockets, Sprockets::Environment.new(root)

    set :assets_prefix, 'assets'
    set :assets_path, -> { File.join(public_folder, assets_prefix) }
    set :assets_manifest_path, -> { File.join(assets_path, 'manifest.json') }
    set :assets_compile, %w(*.png docs.js application.js application.css)

    require 'yajl/json_gem'
    set :docs_prefix, 'docs'
    set :docs_host, -> { File.join('', docs_prefix) }
    set :docs_path, -> { File.join(public_folder, docs_prefix) }
    set :docs_manifest_path, -> { File.join(docs_path, 'docs.json') }
    set :docs, -> { Hash[JSON.parse(File.read(docs_manifest_path)).map! { |doc| [doc['slug'], doc] }] }

    Dir[docs_path, root.join(assets_prefix, '*/')].each do |path|
      sprockets.append_path(path)
    end

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = "/#{assets_prefix}"
      config.public_path = public_folder
    end
  end

  configure :development do
    register Sinatra::Reloader

    require 'active_support/cache'
    sprockets.cache = ActiveSupport::Cache.lookup_store :file_store, root.join('tmp', 'cache', 'assets')

    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path('..', __FILE__)
    BetterErrors.editor = :sublime
  end

  configure :production do
    set :static, false
    set :docs_host, 'http://docs.devdocs.io'

    use Rack::ConditionalGet
    use Rack::ETag
    use Rack::Deflater
    use Rack::Static,
      root: 'public',
      urls: %w(/assets /docs /images /favicon.ico /robots.txt /opensearch.xml /manifest.webapp),
      header_rules: [
        [:all,           {'Cache-Control' => 'private, max-age=0'}],
        ['/assets',      {'Cache-Control' => 'public, max-age=604800'}],
        ['/favicon.ico', {'Cache-Control' => 'public, max-age=86400'}],
        ['/images',      {'Cache-Control' => 'public, max-age=86400'}] ]

    sprockets.js_compressor = Uglifier.new output: { beautify: true, indent_level: 0 }
    sprockets.css_compressor = :sass

    Sprockets::Helpers.configure do |config|
      config.digest = true
      config.asset_host = 'maxcdn.devdocs.io'
      config.manifest = Sprockets::Manifest.new(sprockets, assets_manifest_path)
    end
  end

  helpers do
    include Sinatra::Cookies
    include Sprockets::Helpers

    def browser
      @browser ||= Browser.new ua: request.user_agent
    end

    def unsupported_browser?
      browser.ie? && browser.version.to_i <= 9
    end

    def doc_index_urls
      cookie = cookies[:docs]
      return [] if cookie.nil? || cookie.empty?

      cookie.split('/').inject [] do |result, slug|
        if doc = settings.docs[slug]
          result << File.join('', settings.docs_prefix, doc['index_path'])
        end
        result
      end
    end
  end

  before do
    halt erb :unsupported if unsupported_browser?
  end

  get '/manifest.appcache' do
    content_type 'text/cache-manifest'
    expires 0, :private
    erb :manifest
  end

  get '/' do
    return redirect '/' unless request.query_string.empty?
    erb :index
  end

  %w(about news help).each do |page|
    get "/#{page}" do
      redirect "/#/#{page}", 302
    end
  end

  get '/search' do
    redirect "/#q=#{params[:q]}"
  end

  get '/ping' do
    200
  end

  get %r{\A/(\w+)(\-[\w\-]+)?(/)?(.+)?\z} do |doc, type, slash, rest|
    return 404 unless @doc = settings.docs[doc]

    if !rest && !slash
      redirect "/#{doc}#{type}/"
    elsif rest && rest.end_with?('/')
      redirect "#{doc}#{type}#{slash}#{rest[0...-1]}"
    else
      erb :other
    end
  end

  not_found do
    send_file File.join(settings.public_folder, '404.html'), status: status
  end

  error do
    send_file File.join(settings.public_folder, '500.html'), status: status
  end
end
