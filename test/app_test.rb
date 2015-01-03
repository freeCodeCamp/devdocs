require 'test_helper'
require 'rack/test'
require 'app'

class AppTest < MiniTest::Spec
  include Rack::Test::Methods

  def app
    App
  end

  describe "/" do
    it "works" do
      get '/'
      assert last_response.ok?
    end

    it "redirects without the query string" do
      get '/', foo: 'bar'
      assert last_response.redirect?
      assert_equal 'http://example.org/', last_response['Location']
    end
  end

  describe "/[static-page]" do
    it "redirects to /#/[static-page]" do
      %w(offline about news help).each do |page|
        get "/#{page}"
        assert last_response.redirect?
        assert_equal "http://example.org/#/#{page}", last_response['Location']
      end
    end
  end

  describe "/search" do
    it "redirects to /#q=" do
      get '/search'
      assert last_response.redirect?
      assert_equal 'http://example.org/#q=', last_response['Location']

      get '/search', q: 'foo'
      assert last_response.redirect?
      assert_equal 'http://example.org/#q=foo', last_response['Location']
    end
  end

  describe "/manifest.appcache" do
    it "works" do
      get '/manifest.appcache'
      assert last_response.ok?
    end

    it "works with cookie" do
      set_cookie('docs=css/html')
      get '/manifest.appcache'
      assert last_response.ok?
      assert_includes last_response.body, '/css/index.json'
      assert_includes last_response.body, '/html/index.json'
    end
  end

  describe "/[doc]" do
    it "works when the doc exists" do
      get '/html/'
      assert last_response.ok?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/foo/'
      assert last_response.not_found?
    end

    it "redirects with trailing slash" do
      get '/html'
      assert last_response.redirect?
      assert_equal 'http://example.org/html/', last_response['Location']

      get '/html', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'http://example.org/html/?bar=baz', last_response['Location']
    end
  end

  describe "/[doc]-[type]" do
    it "works when the doc exists" do
      get '/html-foo-bar_42/'
      assert last_response.ok?
    end

    it "returns 404 when the type is blank" do
      get '/html-/'
      assert last_response.not_found?
    end

    it "returns 404 when the type is not alpha-numeric" do
      get '/html-foo:bar/'
      assert last_response.not_found?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/foo-bar/'
      assert last_response.not_found?
    end

    it "redirects with trailing slash" do
      get '/html-foo'
      assert last_response.redirect?
      assert_equal 'http://example.org/html-foo/', last_response['Location']

      get '/html-foo', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'http://example.org/html-foo/?bar=baz', last_response['Location']
    end
  end

  describe "/[doc+type]/[path]" do
    it "works when the doc exists" do
      get '/html/foo'
      assert last_response.ok?

      get '/html-bar/foo'
      assert last_response.ok?
    end

    it "returns 404 when the doc doesn't exist" do
      get '/foo/bar'
      assert last_response.not_found?
    end

    it "redirects without trailing slash" do
      get '/html/foo/'
      assert last_response.redirect?
      assert_equal 'http://example.org/html/foo', last_response['Location']

      get '/html/foo/', bar: 'baz'
      assert last_response.redirect?
      assert_equal 'http://example.org/html/foo?bar=baz', last_response['Location']
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
      %w(maxcdn shopify tw fb re).each do |link|
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
