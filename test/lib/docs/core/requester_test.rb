require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsRequesterTest < Minitest::Spec
  def stub_request(url)
    Typhoeus.stub(url).and_return(Typhoeus::Response.new)
  end

  let :requester do
    Docs::Requester.new(**options)
  end

  let :url do
    'http://example.com'
  end

  let :options do
    Hash.new
  end

  let :block do
    Proc.new {}
  end

  after do
    Typhoeus::Expectation.clear
  end

  describe ".new" do
    it "defaults the :max_concurrency to 20" do
      assert_equal 20, Docs::Requester.new.max_concurrency
      assert_equal 10, Docs::Requester.new(max_concurrency: 10).max_concurrency
    end

    it "duplicates and stores :request_options" do
      options[:request_options] = { params: 'test' }
      assert_equal options[:request_options], requester.request_options
      refute_same options[:request_options], requester.request_options
    end
  end

  describe "#request" do
    context "with a url" do
      it "returns a request" do
        assert_instance_of Docs::Request, requester.request(url)
      end

      describe "the request" do
        it "is queued" do
          request = requester.request(url)
          assert_includes requester.queued_requests, request
        end

        it "has the given url" do
          request = requester.request(url)
          assert_equal url, request.base_url
        end

        it "has the default :request_options" do
          options[:request_options] = { params: 'test' }
          request = requester.request(url)
          assert_equal 'test', request.options[:params]
        end

        it "has the given options" do
          options[:request_options] = { params: '' }
          request = requester.request(url, params: 'test')
          assert_equal 'test', request.options[:params]
        end

        it "has the given block as an on_complete callback" do
          request = requester.request(url, &block)
          assert_includes request.on_complete, block
        end
      end
    end

    context "with an array of urls" do
      let :urls do
        ['one', 'two']
      end

      it "returns an array of requests" do
        result = requester.request(urls, params: 'test', &block)
        assert_instance_of Array, result
        assert_equal urls.length, result.length
        assert result.all? { |obj| obj.instance_of? Docs::Request }
        urls.each_with_index do |url, i|
          assert_equal url, result[i].base_url
          assert_equal 'test', result[i].options[:params]
          assert_includes result[i].on_complete, block
        end
      end

      it "queues the requests in the given order" do
        queue = []
        stub(requester).queue { |request| queue << request }
        assert_equal urls, requester.request(urls).map(&:base_url)
      end
    end
  end

  describe "#on_response" do
    it "returns an array" do
      assert_instance_of Array, requester.on_response
    end

    it "stores a callback" do
      requester.on_response(&block)
      assert_includes requester.on_response, block
    end
  end

  describe "#run" do
    before do
      stub_request(url)
    end

    it "calls the #on_response callbacks after each request" do
      one = 0; requester.on_response { one += 1 }
      two = 0; requester.on_response { two += 2 }

      2.times do |i|
        stub_request url = "example.com/#{i}"
        requester.request(url)
      end

      assert_difference 'one', 2 do
        assert_difference 'two', 4 do
          requester.run
        end
      end
    end

    it "passes the response to the #on_response callbacks" do
      requester.on_response { |arg| @arg = arg }
      request = requester.request(url)
      request.run
      assert @arg
      assert_equal request.response, @arg
    end

    context "when an #on_response callback returns an array" do
      it "requests the urls in the array" do
        requester.on_response { ['one', 'two'] }
        requester.request(url)
        mock(requester).request('one').then.request('two')
        requester.run
      end
    end

    context "with a cache" do
      let :cache_path do
        File.join tmp_path, 'requester_cache'
      end

      let :cache do
        Docs::ResponseCache.new cache_path
      end

      let :options do
        { request_options: { cache: cache } }
      end

      def cache_response(url, body)
        Docs::Request.new(url, cache: cache).response = Typhoeus::Response.new(
          code: 200, headers: {}, body: body, effective_url: url, return_code: :ok)
      end

      after do
        FileUtils.rm_rf cache_path
      end

      it "serves the requests from the cache" do
        cache_response url, 'body'
        requester.on_response { |response| @response = response }
        requester.request(url)
        requester.run
        assert @response.cached?
        assert_equal 'body', @response.body
      end

      it "serves the urls returned by the callbacks from the cache" do
        cache_response url, 'body'
        cache_response 'http://example.com/one', 'one'
        cache_response 'http://example.com/two', 'two'

        bodies = []
        requester.on_response do |response|
          bodies << response.body
          ['http://example.com/one', 'http://example.com/two'] if response.body == 'body'
        end

        requester.request(url)
        requester.run
        assert_equal %w(body one two), bodies
      end

      it "requests the urls that aren't cached" do
        cache_response url, 'body'
        stub_request 'http://example.com/one'

        requester.on_response do |response|
          @count = @count.to_i + 1
          ['http://example.com/one'] if response.cached?
        end

        requester.request(url)
        requester.run
        assert_equal 2, @count
      end
    end
  end
end
