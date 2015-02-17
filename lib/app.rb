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
    set :assets_compile, %w(*.png docs.js application.js application.css application-dark.css)

    require 'yajl/json_gem'
    set :docs_prefix, 'docs'
    set :docs_host, -> { File.join('', docs_prefix) }
    set :docs_path, -> { File.join(public_folder, docs_prefix) }
    set :docs_manifest_path, -> { File.join(docs_path, 'docs.json') }
    set :docs, -> { Hash[JSON.parse(File.read(docs_manifest_path)).map! { |doc| [doc['slug'], doc] }] }
    set :default_docs, %w(css dom dom_events html http javascript)

    set :news_path, -> { File.join(root, assets_prefix, 'javascripts', 'news.json') }
    set :news, -> { JSON.parse(File.read(news_path)) }

    Dir[docs_path, root.join(assets_prefix, '*/')].each do |path|
      sprockets.append_path(path)
    end

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = "/#{assets_prefix}"
      config.public_path = public_folder
    end
  end

  configure :test, :development do
    require 'active_support/per_thread_registry'
    require 'active_support/cache'
    sprockets.cache = ActiveSupport::Cache.lookup_store :file_store, root.join('tmp', 'cache', 'assets')
  end

  configure :development do
    register Sinatra::Reloader

    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path('..', __FILE__)
    BetterErrors.editor = :sublime
  end

  configure :production do
    set :static, false
    set :docs_host, 'http://maxcdn-docs.devdocs.io'

    use Rack::ConditionalGet
    use Rack::ETag
    use Rack::Deflater
    use Rack::Static,
      root: 'public',
      urls: %w(/assets /docs /images /favicon.ico /robots.txt /opensearch.xml /manifest.webapp),
      header_rules: [
        [:all,           {'Cache-Control' => 'no-cache, max-age=0'}],
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

  configure :test do
    set :docs_manifest_path, -> { File.join(root, 'test', 'files', 'docs.json') }
  end

  helpers do
    include Sinatra::Cookies
    include Sprockets::Helpers

    def browser
      @browser ||= Browser.new ua: request.user_agent
    end

    def unsupported_browser?
      browser.ie? && %w(6 7 8 9).include?(browser.version)
    end

    def doc_index_urls
      cookie = cookies[:docs]

      docs = if cookie.nil? || cookie.empty?
        settings.default_docs
      else
        cookie.split('/')
      end

      docs.inject [] do |result, slug|
        if doc = settings.docs[slug]
          result << File.join('', settings.docs_prefix, doc['index_path']) + "?#{doc['mtime']}"
        end
        result
      end
    end

    def doc_index_page?
      @doc && request.path == "/#{@doc['slug']}/"
    end

    def query_string_for_redirection
      request.query_string.empty? ? nil : "?#{request.query_string}"
    end

    def main_stylesheet_path
      stylesheet_paths[cookies[:dark].nil? ? :default : :dark]
    end

    def alternate_stylesheet_path
      stylesheet_paths[cookies[:dark].nil? ? :dark : :default]
    end

    def stylesheet_paths
      @stylesheet_paths ||= {
        default: stylesheet_path('application'),
        dark: stylesheet_path('application-dark')
      }
    end

    def size
      @size ||= cookies[:size].nil? ? '18rem' : "#{cookies[:size]}px"
    end
  end

  before do
    halt erb :unsupported if unsupported_browser?
  end

  get '/manifest.appcache' do
    content_type 'text/cache-manifest'
    expires 0, :'no-cache'
    erb :manifest
  end

  get '/' do
    return redirect '/' unless request.query_string.empty?
    erb :index
  end

  %w(offline about news help).each do |page|
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

  get '/s/maxcdn' do
    redirect 'https://www.maxcdn.com/?utm_source=devdocs&utm_medium=banner&utm_campaign=devdocs'
  end

  get '/s/shopify' do
    redirect 'http://www.shopify.com/careers?utm_source=devdocs&utm_medium=banner&utm_campaign=devdocs'
  end

  get %r{\A/feed(?:\.atom)?\z} do
    content_type 'application/atom+xml'
    settings.news_feed
  end

  get '/s/tw' do
    redirect 'https://twitter.com/intent/tweet?url=http%3A%2F%2Fdevdocs.io&via=DevDocs&text=All-in-one%2C%20offline%20API%20documentation%20browser%3A'
  end

  get '/s/fb' do
    redirect 'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fdevdocs.io'
  end

  get '/s/re' do
    redirect 'http://www.reddit.com/submit?url=http%3A%2F%2Fdevdocs.io&title=All-in-one%2C%20offline%20API%20documentation%20browser&resubmit=true'
  end

  get %r{\A/(\w+)(\-[\w\-]+)?(/.*)?\z} do |doc, type, rest|
    return 404 unless @doc = settings.docs[doc]

    if rest.nil?
      redirect "/#{doc}#{type}/#{query_string_for_redirection}"
    elsif rest.length > 1 && rest.end_with?('/')
      redirect "/#{doc}#{type}#{rest[0...-1]}#{query_string_for_redirection}"
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

  configure do
    require 'rss'
    feed = RSS::Maker.make('atom') do |maker|
      maker.channel.id = 'tag:devdocs.io,2014:/feed'
      maker.channel.title = 'DevDocs'
      maker.channel.author = 'DevDocs'
      maker.channel.updated = "#{settings.news.first.first}T14:00:00Z"

      maker.channel.links.new_link do |link|
        link.rel = 'self'
        link.href = 'http://devdocs.io/feed.atom'
        link.type = 'application/atom+xml'
      end

      maker.channel.links.new_link do |link|
        link.rel = 'alternate'
        link.href = 'http://devdocs.io/'
        link.type = 'text/html'
      end

      news.each_with_index do |news, i|
        maker.items.new_item do |item|
          item.id = "tag:devdocs.io,2014:News/#{settings.news.length - i}"
          item.title = news[1].split("\n").first.gsub(/<\/?[^>]*>/, '')
          item.description do |desc|
            desc.content = news[1..-1].join.gsub("\n", '<br>').gsub('href="/', 'href="http://devdocs.io/')
            desc.type = 'html'
          end
          item.updated = "#{news.first}T14:00:00Z"
          item.published = "#{news.first}T14:00:00Z"
          item.links.new_link do |link|
            link.rel = 'alternate'
            link.href = 'http://devdocs.io/'
            link.type = 'text/html'
          end
        end
      end
    end

    set :news_feed, feed.to_s
  end
end
