require 'test_helper'
require 'rack/test'
require 'app'

class AppTest < MiniTest::Spec
  include Rack::Test::Methods

  MODERN_BROWSER = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:39.0) Gecko/20100101 Firefox/39.0'

  def app
    App
  end

  before do
    current_session.env('HTTPS', 'on')
  end

  it 'redirects to HTTPS' do
    get 'http://example.com/test?q=1', {}, 'HTTPS' => 'off'
    assert last_response.redirect?
    assert_equal 'https://example.com/test?q=1', last_response['Location']
  end

  describe "/" do
    it "works" do
      get '/'
      assert last_response.ok?
    end

    it "redirects to /#q= when there is a 'q' query param" do
      get '/search', q: 'foo'
      assert last_response.redirect?
      assert_equal 'https://example.org/#q=foo', last_response['Location']
    end

    it "redirects without the query string" do
      get '/', foo: 'bar'
      assert last_response.redirect?
      assert_equal 'https://example.org/', last_response['Location']
    end

    it "sets default size" do
      get '/'
      assert_includes last_response.body, 'data-size="20rem"'
    end

    it "sets size from cookie" do
      set_cookie('size=42')
      get '/'
      assert_includes last_response.body, 'data-size="42px"'
    end

    it "sets layout from cookie" do
      set_cookie('layout=foo')
      get '/'
      assert_includes last_response.body, '<body class="foo">'
    end

    it "sets the <html> theme from cookie" do
      get '/'
      assert_match %r{<html [^>]*class="[^\"]*_theme-default}, last_response.body
      refute_includes last_response.body, '_theme-dark'

      set_cookie('dark=1')

      get '/'
      assert_match %r{<html [^>]*class="[^\"]*_theme-dark}, last_response.body
      refute_includes last_response.body, '_theme-default'
    end
  end

  describe "/[static-page]" do
    it "redirects to /#/[static-page] by default" do
      %w(offline about news help).each do |page|
        get "/#{page}", {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
        assert last_response.redirect?
        assert_equal "https://example.org/#/#{page}", last_response['Location']
      end
    end

    it "redirects via JS cookie when a cookie exists" do
      %w(offline about news help).each do |page|
        set_cookie('foo=bar')
        get "/#{page}", {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
        assert last_response.redirect?
        assert_equal 'https://example.org/', last_response['Location']
        assert last_response['Set-Cookie'].start_with?("initial_path=%2F#{page}; path=/; expires=")
      end
    end
  end

  describe "/search" do
    it "redirects to /#q=" do
      get '/search'
      assert last_response.redirect?
      assert_equal 'https://example.org/#q=', last_response['Location']

      get '/search', q: 'foo'
      assert last_response.redirect?
      assert_equal 'https://example.org/#q=foo', last_response['Location']
    end
  end

  describe "/manifest.appcache" do
    it "works" do
      get '/manifest.appcache'
      assert last_response.ok?
    end

    it "works with cookie" do
      set_cookie('docs=css/html~5')
      get '/manifest.appcache'
      assert last_response.ok?
      assert_includes last_response.body, '/css/index.json?1420139788'
      assert_includes last_response.body, '/html~5/index.json?1420139791'
    end

    it "ignores invalid docs in the cookie" do
      set_cookie('docs=foo')
      get '/manifest.appcache'
      assert last_response.ok?
      refute_includes last_response.body, 'foo'
    end

    it "sets default size" do
      get '/manifest.appcache'
      assert_includes last_response.body, '20rem'
    end

    it "sets size from cookie" do
      set_cookie('size=42')
      get '/manifest.appcache'
      assert_includes last_response.body, '42px'
    end

    it "sets layout from cookie" do
      set_cookie('layout=foo_layout')
      get '/manifest.appcache'
      assert_includes last_response.body, 'foo_layout'
    end
  end

  describe "/[doc]" do
    it "renders when the doc exists and isn't enabled" do
      set_cookie('docs=html~5')
      get '/html~4/', {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
      assert last_response.ok?
    end

    it "renders when the doc exists, is a default doc, and all docs are enabled" do
      set_cookie('docs=')
      get '/css/', {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
      assert last_response.ok?
    end

    it "redirects via JS cookie when the doc exists and is enabled" do
      set_cookie('docs=html~5')
      get '/html~5/', {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
      assert last_response.redirect?
      assert_equal 'https://example.org/', last_response['Location']
      assert last_response['Set-Cookie'].start_with?("initial_path=%2Fhtml%7E5%2F; path=/; expires=")
    end

    it "renders when the doc exists, has no version in the path, and isn't enabled" do
      get '/html/', {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
      assert last_response.ok?
    end

    it "redirects via JS cookie when the doc exists, has no version in the path, and a version is enabled" do
      set_cookie('docs=html~5')
      get '/html/', {}, 'HTTP_USER_AGENT' => MODERN_BROWSER
      assert last_response.redirect?
      assert_equal 'https://example.org/', last_response['Location']
      assert last_response['Set-Cookie'].start_with?("initial_path=%2Fhtml%2F; path=/; expires=")
    end

    it "renders when the doc exists and is enabled, and the request is from Googlebot" do
      set_cookie('docs=html')
      get '/html/', {}, 'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +https://www.google.com/bot.html)'
      assert last_response.ok?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/html~6/'
      assert last_response.not_found?
    end

    it "decodes '~' properly" do
      get '/html%7E5/'
      assert last_response.ok?

      get '/html%7E42/'
      assert last_response.not_found?
    end

    it "redirects with trailing slash" do
      get '/html'
      assert last_response.redirect?
      assert_equal 'https://example.org/html/', last_response['Location']

      get '/html', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'https://example.org/html/?bar=baz', last_response['Location']
    end

    it "redirects old docs" do
      get '/iojs/'
      assert last_response.redirect?
      assert_equal 'https://example.org/node/', last_response['Location']
    end
  end

  describe "/[doc]-[type]" do
    it "works when the doc exists" do
      get '/html~4-foo-bar_42/'
      assert last_response.ok?
      assert_includes last_response.body, 'data-doc="{&quot;name&quot;:&quot;HTML&quot;,&quot;slug&quot;:&quot;html~4&quot;'
    end

    it "works when the doc has no version in the path and a version exists" do
      get '/html-foo-bar_42/'
      assert last_response.ok?
      assert_includes last_response.body, 'data-doc="{&quot;name&quot;:&quot;HTML&quot;,&quot;slug&quot;:&quot;html~5&quot;'
    end

    it "returns 404 when the type is blank" do
      get '/css-/'
      assert last_response.not_found?
    end

    it "returns 404 when the type is not alpha-numeric" do
      get '/css-foo:bar/'
      assert last_response.not_found?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/html~6-bar/'
      assert last_response.not_found?
    end

    it "redirects with trailing slash" do
      get '/css-foo'
      assert last_response.redirect?
      assert_equal 'https://example.org/css-foo/', last_response['Location']

      get '/css-foo', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'https://example.org/css-foo/?bar=baz', last_response['Location']
    end

    it "redirects old docs" do
      get '/yii1-foo/'
      assert last_response.redirect?
      assert_equal 'https://example.org/yii~1.1-foo/', last_response['Location']
    end
  end

  describe "/[doc+type]/[path]" do
    it "works when the doc exists" do
      get '/css/foo'
      assert last_response.ok?

      get '/css-bar/foo'
      assert last_response.ok?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/foo/bar'
      assert last_response.not_found?
    end

    it "redirects without trailing slash" do
      get '/css/foo/'
      assert last_response.redirect?
      assert_equal 'https://example.org/css/foo', last_response['Location']

      get '/css/foo/', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'https://example.org/css/foo?bar=baz', last_response['Location']
    end

    it "redirects old docs" do
      get '/python2/foo'
      assert last_response.redirect?
      assert_equal 'https://example.org/python~2.7/foo', last_response['Location']
    end
  end

  describe "/docs.json" do
    it "returns to the asset path" do
      get '/docs.json'
      assert last_response.redirect?
      assert_equal 'https://example.org/assets/docs.json', last_response['Location']
    end
  end

  describe "/application.js" do
    it "returns to the asset path" do
      get '/application.js'
      assert last_response.redirect?
      assert_equal 'https://example.org/assets/application.js', last_response['Location']
    end
  end

  describe "/application.css" do
    it "returns to the asset path" do
      get '/application.css'
      assert last_response.redirect?
      assert_equal 'https://example.org/assets/application.css', last_response['Location']
    end
  end

  describe "/feed" do
    it "returns an atom feed" do
      get '/feed'
      assert last_response.ok?
      assert_equal 'application/atom+xml', last_response['Content-Type']

      get '/feed.atom'
      assert last_response.ok?
      assert_equal 'application/atom+xml', last_response['Content-Type']
    end
  end

  describe "/s/[link]" do
    it "redirects" do
      %w(maxcdn shopify code-school jetbrains tw fb re).each do |link|
        get "/s/#{link}"
        assert last_response.redirect?
      end
    end
  end

  describe "/ping" do
    it "works" do
      get '/ping'
      assert last_response.ok?
    end
  end

  describe "404" do
    it "works" do
      get '/foo'
      assert last_response.not_found?
    end
  end
end
