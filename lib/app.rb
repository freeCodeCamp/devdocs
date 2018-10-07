# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :app

class App < Sinatra::Application
  Bundler.require environment
  require 'sinatra/cookies'
  require 'tilt/erubi'
  require 'active_support/notifications'

  Rack::Mime::MIME_TYPES['.webapp'] = 'application/x-web-app-manifest+json'

  configure do
    use Rack::SslEnforcer, only_environments: ['production', 'test'], hsts: false, force_secure_cookies: false

    set :sentry_dsn, ENV['SENTRY_DSN']
    set :protection, except: [:frame_options, :xss_header]

    set :root, Pathname.new(File.expand_path('../..', __FILE__))
    set :sprockets, Sprockets::Environment.new(root)

    set :cdn_origin, ''

    set :assets_prefix, 'assets'
    set :assets_path, File.join(public_folder, assets_prefix)
    set :assets_manifest_path, File.join(assets_path, 'manifest.json')
    set :assets_compile, %w(*.png docs.js docs.json application.js application.css application-dark.css)

    require 'yajl/json_gem'
    set :docs_prefix, 'docs'
    set :docs_origin, File.join('', docs_prefix)
    set :docs_path, File.join(public_folder, docs_prefix)
    set :docs_manifest_path, File.join(docs_path, 'docs.json')
    set :default_docs, %w(css dom dom_events html http javascript)
    set :news_path, File.join(root, assets_prefix, 'javascripts', 'news.json')

    set :csp, false

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
    require 'active_support/per_thread_registry'
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
    set :cdn_origin, 'https://cdn.devdocs.io'
    set :docs_origin, '//docs.devdocs.io'
    set :csp, "default-src 'self' *; script-src 'self' 'nonce-devdocs' http://cdn.devdocs.io https://cdn.devdocs.io https://www.google-analytics.com https://secure.gaug.es http://*.jquery.com https://*.jquery.com; font-src 'none'; style-src 'self' 'unsafe-inline' *; img-src 'self' * data:;"

    use Rack::ConditionalGet
    use Rack::ETag
    use Rack::Deflater
    use Rack::Static,
      root: 'public',
      urls: %w(/assets /docs/ /images /favicon.ico /robots.txt /opensearch.xml /mathml.css /manifest.json),
      header_rules: [
        [:all,              { 'Cache-Control' => 'no-cache, max-age=0'    }],
        ['/assets',         { 'Cache-Control' => 'public, max-age=604800' }],
        ['/docs',           { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/images',         { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/favicon.ico',    { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/robots.txt',     { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/opensearch.xml', { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/mathml.css',     { 'Cache-Control' => 'public, max-age=86400'  }],
        ['/manifest.json',  { 'Cache-Control' => 'public, max-age=86400'  }]
      ]

    sprockets.js_compressor = Uglifier.new output: { beautify: true, indent_level: 0 }
    sprockets.css_compressor = :sass

    Sprockets::Helpers.configure do |config|
      config.digest = true
      config.asset_host = 'cdn.devdocs.io'
      config.manifest = Sprockets::Manifest.new(sprockets, assets_manifest_path)
    end
  end

  configure :test do
    set :docs_manifest_path, File.join(root, 'test', 'files', 'docs.json')
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
    include Sinatra::Cookies
    include Sprockets::Helpers

    def memoized_cookies
      @memoized_cookies ||= cookies.to_hash
    end

    def canonical_origin
      "https://#{request.host_with_port}"
    end

    def browser
      @browser ||= Browser.new(request.user_agent)
    end

    UNSUPPORTED_IE_VERSIONS = %w(6 7 8 9).freeze

    def unsupported_browser?
      browser.ie? && UNSUPPORTED_IE_VERSIONS.include?(browser.version)
    end

    def docs
      @docs ||= begin
        cookie = memoized_cookies['docs']

        if cookie.nil?
          settings.default_docs
        else
          cookie.split('/')
        end
      end
    end

    def find_doc(slug)
      settings.docs[slug] || begin
        settings.docs.each do |_, doc|
          return doc if doc['slug_without_version'] == slug
        end
        nil
      end
    end

    def user_has_docs?(slug)
      docs.include?(slug) || begin
        slug = "#{slug}~"
        docs.any? { |_slug| _slug.start_with?(slug) }
      end
    end

    def doc_index_urls
      docs.each_with_object [] do |slug, result|
        if doc = settings.docs[slug]
          result << File.join('', settings.docs_prefix, slug, 'index.json') + "?#{doc['mtime']}"
        end
      end
    end

    def doc_index_page?
      @doc && (request.path == "/#{@doc['slug']}/" || request.path == "/#{@doc['slug_without_version']}/")
    end

    def query_string_for_redirection
      request.query_string.empty? ? nil : "?#{request.query_string}"
    end

    def manifest_asset_urls
      @@manifest_asset_urls ||= [
        javascript_path('application', asset_host: false),
        stylesheet_path('application'),
        stylesheet_path('application-dark'),
        image_path('docs-1.png'),
        image_path('docs-1@2x.png'),
        image_path('docs-2.png'),
        image_path('docs-2@2x.png'),
        asset_path('docs.js')
      ]
    end

    def main_stylesheet_path
      stylesheet_paths[dark_theme? ? :dark : :default]
    end

    def alternate_stylesheet_path
      stylesheet_paths[dark_theme? ? :default : :dark]
    end

    def stylesheet_paths
      @@stylesheet_paths ||= {
        default: stylesheet_path('application'),
        dark: stylesheet_path('application-dark')
      }
    end

    def app_size
      @app_size ||= memoized_cookies['size'].nil? ? '20rem' : "#{memoized_cookies['size']}px"
    end

    def app_layout
      memoized_cookies['layout']
    end

    def app_theme
      @app_theme ||= memoized_cookies['dark'].nil? ? 'default' : 'dark'
    end

    def dark_theme?
      app_theme == 'dark'
    end

    def redirect_via_js(path) # courtesy of HTML5 App Cache
      response.set_cookie :initial_path, value: path, expires: Time.now + 15, path: '/'
      redirect '/', 302
    end

    def supports_js_redirection?
      browser.modern? && !memoized_cookies.empty?
    end
  end

  before do
    halt erb :unsupported if unsupported_browser?
  end

  OUT_HOST = 'out.devdocs.io'.freeze

  before do
    if request.host == OUT_HOST && !request.path.start_with?('/s/')
      query_string = "?#{request.query_string}" unless request.query_string.empty?
      redirect "https://devdocs.io#{request.path}#{query_string}", 302
    end
  end

  get '/manifest.appcache' do
    content_type 'text/cache-manifest'
    expires 0, :'no-cache'
    erb :manifest
  end

  get '/' do
    return redirect "/#q=#{params[:q]}" if params[:q]
    return redirect '/' unless request.query_string.empty? # courtesy of HTML5 App Cache
    response.headers['Content-Security-Policy'] = settings.csp if settings.csp
    erb :index
  end

  %w(settings offline about news help).each do |page|
    get "/#{page}" do
      if supports_js_redirection?
        redirect_via_js "/#{page}"
      else
        redirect "/#/#{page}", 302
      end
    end
  end

  get '/search' do
    redirect "/#q=#{params[:q]}"
  end

  get '/ping' do
    200
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
    elsif user_has_docs?(doc) && supports_js_redirection?
      redirect_via_js(request.path)
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
