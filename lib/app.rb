# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :app

# Redirects the requests that aren't encrypted and tells the browser to stay on
# https afterwards. (This used to be the rack-ssl-enforcer gem, which hasn't
# been updated since 2016.)
class HttpsRedirect
  HSTS = 'max-age=31536000; includeSubDomains'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    unless request.scheme == 'https'
      return [301, {'location' => request.url.sub(/\Ahttp:/, 'https:'), 'content-type' => 'text/plain'}, []]
    end

    status, headers, body = @app.call(env)
    headers['strict-transport-security'] = HSTS
    [status, headers, body]
  end
end

class App < Sinatra::Application
  Bundler.require environment
  require 'tilt/erubi'
  require 'active_support/notifications'

  Rack::Mime::MIME_TYPES['.webapp'] = 'application/x-web-app-manifest+json'

  configure do
    use HttpsRedirect if production? || test?

    set :sentry_dsn, ENV['SENTRY_DSN']
    set :protection, except: [:frame_options, :xss_header]

    set :root, Pathname.new(File.expand_path('../..', __FILE__))
    set :sprockets, Sprockets::Environment.new(root)

    set :assets_prefix, 'assets'
    set :assets_path, File.join(public_folder, assets_prefix)
    set :assets_manifest_path, File.join(assets_path, 'manifest.json')
    # Every ES module in the app, by the logical path the import map keys on.
    # The vendored libraries are concatenated into vendor.js, and unsupported.js
    # guards the module graph from outside it, so neither is a module; the debug
    # module is only served outside production.
    set :js_modules, Dir.glob('**/*.js{,.erb}', base: root.join('assets', 'javascripts'))
                        .reject { |path| path.start_with?('vendor/') ||
                                         %w(vendor.js unsupported.js).include?(path) }
                        .map { |path| path.delete_suffix('.erb') }
                        .sort
                        .freeze

    set :assets_compile, %w(sprites/docs.webp sprites/docs@2x.webp docs.json vendor.js unsupported.js application.css application-dark.css) + js_modules

    require 'json'
    set :docs_prefix, 'docs'
    set :docs_origin, File.join('', docs_prefix)
    set :docs_path, File.join(public_folder, docs_prefix)
    set :docs_manifest_path, File.join(docs_path, 'docs.json')
    set :default_docs, %w(css dom html http javascript)
    set :news_path, File.join(root, assets_prefix, 'javascripts', 'news.json')

    set :csp, false

    require 'docs'
    Docs.generate_manifest
    set :docs_aliases, Docs.aliases

    Dir[docs_path, root.join(assets_prefix, '*/')].each do |path|
      sprockets.append_path(path)
    end

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix = "/#{assets_prefix}"
      config.public_path = public_folder
      config.protocol = :relative
    end
  end

  configure :test, :development do
    require 'thor'
    load 'tasks/sprites.thor'

    SpritesCLI.new.invoke(:generate, [], :disable_optimization => true)

    require 'active_support/cache'
    sprockets.cache = ActiveSupport::Cache.lookup_store :file_store, root.join('tmp', 'cache', 'assets', environment.to_s)
  end

  configure :development do
    register Sinatra::Reloader

    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path('..', __FILE__)
    BetterErrors.editor = :sublime

    set :csp, "default-src 'self' *; script-src 'self' 'nonce-devdocs' *; font-src 'none'; style-src 'self' 'unsafe-inline' *; img-src 'self' * data:;"
  end

  configure :production do
    set :static, false
    set :docs_origin, '//documents.devdocs.io'
    set :csp, "default-src 'self' *; script-src 'self' 'nonce-devdocs' https://www.google-analytics.com https://secure.gaug.es https://*.jquery.com; font-src 'none'; style-src 'self' 'unsafe-inline' *; img-src 'self' * data:;"

    use Rack::ConditionalGet
    use Rack::ETag
    use Rack::Deflater
    use Rack::Static,
      root: 'public',
      urls: %w(/assets /docs/ /images /favicon.ico /robots.txt /opensearch.xml /mathml.css /manifest.json),
      header_rules: [
        [:all,              { 'Cache-Control' => 'no-cache, max-age=0'    }],
        # Every asset under /assets is content-digested, so a URL's body never
        # changes. The import map in the (uncached) HTML is what moves a client
        # onto a new build, all of it at once.
        ['/assets',         { 'Cache-Control' => 'public, max-age=31536000, immutable' }],
        ['/docs',           { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/images',         { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/favicon.ico',    { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/robots.txt',     { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/opensearch.xml', { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/mathml.css',     { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/manifest.json',  { 'Cache-Control' => 'public, max-age=86400'  }]
      ]

    sprockets.js_compressor = Terser.new
    sprockets.css_compressor = :sass

    Sprockets::Helpers.configure do |config|
      config.digest = true
      config.manifest = Sprockets::Manifest.new(sprockets, assets_manifest_path)
    end
  end

  configure :test do
    set :docs_manifest_path, File.join(root, 'test', 'files', 'docs.json')
    set :docs_path, File.join(root, 'test', 'files', 'docs')
  end

  def self.parse_docs
    Hash[JSON.parse(File.read(docs_manifest_path)).map! { |doc|
      doc['full_name'] = doc['name'].dup
      doc['full_name'] << " #{doc['version']}" if doc['version'] && !doc['version'].empty?
      doc['slug_without_version'] = doc['slug'].split('~').first
      [doc['slug'], doc]
    }]
  end

  def self.parse_news
    JSON.parse(File.read(news_path))
  end

  configure :development, :test do
    set :docs, -> { parse_docs }
    set :news, -> { parse_news }
  end

  configure :production do
    set :docs, parse_docs
    set :news, parse_news
  end

  helpers do
    include Sprockets::Helpers

    def canonical_origin
      "https://#{request.host_with_port}"
    end

    def find_doc(slug)
      settings.docs[slug] || begin
        settings.docs.each do |_, doc|
          return doc if doc['slug_without_version'] == slug
        end
        nil
      end
    end

    def doc_index_page?
      @doc && (request.path == "/#{@doc['slug']}/" || request.path == "/#{@doc['slug_without_version']}/")
    end

    def query_string_for_redirection
      request.query_string.empty? ? nil : "?#{request.query_string}"
    end

    # Every module the import map has to cover. The debug module is only
    # served outside production, where it patches the boot in console timers.
    def mapped_js_modules
      @mapped_js_modules ||=
        App.production? ? App.js_modules - ['debug.js'] : App.js_modules
    end

    # The modules the app itself pulls in. docs.js is its own entry because
    # only the full app needs the catalog, and debug.js is its own entry
    # because it has to run before the boot it wraps.
    def page_js_modules
      @page_js_modules ||= mapped_js_modules - ['debug.js', 'docs.js']
    end

    # Maps every module's source URL onto its content-digested one.
    #
    # The modules import each other by relative path. The browser resolves
    # those against the importing module's own (digested) URL, which yields the
    # undigested path, and then rewrites it through this map. That keeps the
    # source free of digests while every response stays immutable.
    #
    # It also makes a deploy atomic: the map ships inside the HTML, which is
    # never cached, so a client reads one build's map and fetches that build's
    # modules. It can't end up with half of one build and half of another.
    def import_map_json
      imports = mapped_js_modules.to_h do |logical|
        ["/#{App.assets_prefix}/#{logical}", javascript_path(logical)]
      end
      JSON.generate(imports: imports)
    end

    # Preloads the whole graph so the browser fetches it in parallel instead of
    # discovering one level of imports per round trip.
    # @param extra [Array<String>] Entries this page loads on top of the app's.
    def module_preload_tags(*extra)
      (page_js_modules + extra)
        .map { |logical| %(<link rel="modulepreload" href="#{javascript_path(logical)}">) }
        .join("\n")
    end

    def service_worker_asset_urls
      @@service_worker_asset_urls ||= [
        *mapped_js_modules.map { |logical| javascript_path(logical) },
        javascript_path('vendor'),
        javascript_path('unsupported'),
        stylesheet_path('application'),
        image_path('sprites/docs.webp'),
        image_path('sprites/docs@2x.webp'),
      ].compact
    end

    # Returns a cache name for the service worker to use which changes if any of the assets changes
    # When a manifest exist, this name is only created once based on the asset manifest because it never changes without a server restart
    # If a manifest does not exist, it is created every time this method is called because the assets can change while the server is running
    def service_worker_cache_name
      if File.exist?(App.assets_manifest_path)
        if defined?(@@service_worker_cache_name)
          return @@service_worker_cache_name
        end

        digest = Sprockets::Manifest
                   .new(nil, App.assets_manifest_path)
                   .files
                   .values
                   .map {|file| file["digest"]}
                   .join

        return @@service_worker_cache_name ||= Digest::MD5.hexdigest(digest)
      else
        paths = App.sprockets
                  .each_file
                  .to_a
                  .reject {|file| file.start_with?(App.docs_path)}

        return App.sprockets.pack_hexdigest(App.sprockets.files_digest(paths))
      end
    end

  end

  OUT_HOST = 'out.devdocs.io'.freeze

  before do
    if request.host == OUT_HOST && !request.path.start_with?('/s/')
      query_string = "?#{request.query_string}" unless request.query_string.empty?
      redirect "https://devdocs.io#{request.path}#{query_string}", 302
    end
  end

  get '/service-worker.js' do
    content_type 'application/javascript'
    expires 0, :'no-cache'
    erb :'service-worker.js'
  end

  get '/' do
    return redirect "/#q=#{params[:q]}" if params[:q]
    return redirect '/' unless request.query_string.empty?
    response.headers['Content-Security-Policy'] = settings.csp if settings.csp
    erb :index
  end

  %w(settings offline about news help).each do |page|
    get "/#{page}" do
      response.headers['Content-Security-Policy'] = settings.csp if settings.csp
      erb :index
    end
  end

  get '/search' do
    redirect "/#q=#{params[:q]}"
  end

  get '/ping' do
    200
  end

  require 'mcp/server'

  post '/mcp' do
    content_type :json
    begin
      payload = JSON.parse(request.body.read)
      response = Mcp::Server.handle(payload, settings)
      if response.nil?
        # The payload was a notification, which takes no response.
        status 202
        ''
      else
        response.to_json
      end
    rescue JSON::ParserError => err
      error_response(nil, -32700, "Parse error: #{err.message}").to_json
    rescue => err
      error_response(nil, -32603, "Internal error: #{err.message}").to_json
    end
  end

  def error_response(id, code, message)
    { 'jsonrpc' => '2.0', 'id' => id, 'error' => { 'code' => code, 'message' => message } }
  end

  %w(docs.json application.js application.css).each do |asset|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      get '/#{asset}' do
        redirect asset_path('#{asset}', protocol: 'http')
      end
    CODE
  end

  {
    '/s/maxcdn'           => 'https://www.maxcdn.com/?utm_source=devdocs&utm_medium=banner&utm_campaign=devdocs',
    '/s/shopify'          => 'https://www.shopify.com/careers?utm_source=devdocs&utm_medium=banner&utm_campaign=devdocs',
    '/s/jetbrains'        => 'https://www.jetbrains.com/?utm_source=devdocs&utm_medium=sponsorship&utm_campaign=devdocs',
    '/s/jetbrains/ruby'   => 'https://www.jetbrains.com/ruby/?utm_source=devdocs&utm_medium=sponsorship&utm_campaign=devdocs',
    '/s/jetbrains/python' => 'https://www.jetbrains.com/pycharm/?utm_source=devdocs&utm_medium=sponsorship&utm_campaign=devdocs',
    '/s/jetbrains/c'      => 'https://www.jetbrains.com/clion/?utm_source=devdocs&utm_medium=sponsorship&utm_campaign=devdocs',
    '/s/jetbrains/web'    => 'https://www.jetbrains.com/webstorm/?utm_source=devdocs&utm_medium=sponsorship&utm_campaign=devdocs',
    '/s/code-school'      => 'https://www.codeschool.com/?utm_campaign=devdocs&utm_content=homepage&utm_source=devdocs&utm_medium=sponsorship',
    '/s/tw'               => 'https://twitter.com/intent/tweet?url=http%3A%2F%2Fdevdocs.io&via=DevDocs&text=All-in-one%20API%20documentation%20browser%20with%20offline%20mode%20and%20instant%20search%3A',
    '/s/fb'               => 'https://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fdevdocs.io',
    '/s/re'               => 'https://www.reddit.com/submit?url=http%3A%2F%2Fdevdocs.io&title=All-in-one%20API%20documentation%20browser%20with%20offline%20mode%20and%20instant%20search&resubmit=true'
  }.each do |path, url|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      get '#{path}' do
        redirect '#{url}'
      end
    CODE
  end

  %w(/maxcdn /maxcdn/).each do |path|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      get '#{path}' do
        410
      end
    CODE
  end

  {
    '/tips'                   => '/help',
    '/css-data-types/'        => '/css-values-units/',
    '/css-at-rules/'          => '/?q=css%20%40',
    '/dom/window/setinterval' => '/dom/windoworworkerglobalscope/setinterval',
    '/html/article'           => '/html/element/article',
    '/html-html5/'            => 'html-elements/',
    '/html-standard/'         => 'html-elements/',
    '/http-status-codes/'     => '/http-status/',
    '/ruby/bignum'            => '/ruby~2.3/bignum',
    '/ruby/fixnum'            => '/ruby~2.3/fixnum',
  }.each do |path, url|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      get '#{path}' do
        redirect '#{url}', 301
      end
    CODE
  end

  get %r{/feed(?:\.atom)?} do
    content_type 'application/atom+xml'
    settings.news_feed
  end

  DOC_REDIRECTS = {
    'iojs' => 'node',
    'node_lts' => 'node~6_lts',
    'node~4.2_lts' => 'node~4_lts',
    'yii1' => 'yii~1.1',
    'python2' => 'python~2.7',
    'xpath' => 'xslt_xpath',
    'angular~4_typescript' => 'angular',
    'angular~2_typescript' => 'angular~2',
    'angular~2.0_typescript' => 'angular~2',
    'angular~1.5' => 'angularjs~1.5',
    'angular~1.4' => 'angularjs~1.4',
    'angular~1.3' => 'angularjs~1.3',
    'angular~1.2' => 'angularjs~1.2',
    'codeigniter~3.0' => 'codeigniter~3',
    'pytorch~1' => 'pytorch~1.13',
    'pytorch~2' => 'pytorch',
    'webpack~2' => 'webpack'
  }

  get %r{/([\w~\.%]+)(\-[\w\-]+)?(/.*)?} do |doc, type, rest|
    doc.sub! '%7E', '~'

    if DOC_REDIRECTS.key?(doc)
      return redirect "/#{DOC_REDIRECTS[doc]}#{type}#{rest}", 301
    end

    if rest && doc == 'angular' && rest.start_with?('/ng')
      return redirect "/angularjs/api#{rest}", 301
    end

    if rest && doc == 'dom'
      if rest.start_with?('/windowtimers')
        return redirect "/dom#{rest.sub('windowtimers', 'windoworworkerglobalscope')}", 301
      end

      if rest.start_with?('/window/url.')
        return redirect "/dom#{rest.sub('window/url.', 'url/')}", 301
      end

      if rest.start_with?('/window.')
        return redirect "/dom#{rest.sub('window.', 'window/')}", 301
      end

      if rest.start_with?('/element.')
        return redirect "/dom#{rest.sub('element.', 'element/')}", 301
      end

      if rest.start_with?('/event.')
        return redirect "/dom#{rest.sub('event.', 'event/')}", 301
      end

      if rest.start_with?('/document.')
        return redirect "/dom#{rest.sub('document.', 'document/')}", 301
      end
    end

    return 404 unless @doc = find_doc(doc)

    if rest.nil?
      redirect "/#{doc}#{type}/#{query_string_for_redirection}"
    elsif rest.length > 1 && rest.end_with?('/')
      redirect "/#{doc}#{type}#{rest[0...-1]}#{query_string_for_redirection}"
    else
      response.headers['Content-Security-Policy'] = settings.csp if settings.csp
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
        link.href = 'https://devdocs.io/feed.atom'
        link.type = 'application/atom+xml'
      end

      maker.channel.links.new_link do |link|
        link.rel = 'alternate'
        link.href = 'https://devdocs.io/'
        link.type = 'text/html'
      end

      news.each_with_index do |news, i|
        maker.items.new_item do |item|
          item.id = "tag:devdocs.io,2014:News/#{settings.news.length - i}"
          item.title = news[1].split("\n").first.gsub(/<\/?[^>]*>/, '')
          item.description do |desc|
            desc.content = news[1..-1].join.gsub("\n", '<br>').gsub('href="/', 'href="https://devdocs.io/')
            desc.type = 'html'
          end
          item.updated = "#{news.first}T14:00:00Z"
          item.published = "#{news.first}T14:00:00Z"
          item.links.new_link do |link|
            link.rel = 'alternate'
            link.href = 'https://devdocs.io/'
            link.type = 'text/html'
          end
        end
      end
    end

    set :news_feed, feed.to_s
  end
end
