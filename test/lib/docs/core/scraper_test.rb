require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsScraperTest < MiniTest::Spec
  class Scraper < Docs::Scraper
    self.type = 'scraper'
    self.base_url = 'http://example.com/'
    self.root_path = '/root'
    self.initial_paths = ['/initial']
    self.html_filters = Docs::FilterStack.new
    self.text_filters = Docs::FilterStack.new
  end

  let :scraper do
    Scraper.new.tap do |scraper|
      scraper.extend FakeInstrumentation
    end
  end

  let :response do
    Struct.new(:body, :url).new
  end

  describe ".inherited" do
    let :subclass do
      Class.new Scraper
    end

    it "sets .type" do
      assert_equal Scraper.type, subclass.type
    end

    it "sets .root_path" do
      assert_equal Scraper.root_path, subclass.root_path
    end

    it "duplicates .initial_paths" do
      stub(Scraper).initial_paths { ['path'] }
      assert_equal Scraper.initial_paths, subclass.initial_paths
      refute_same Scraper.initial_paths, subclass.initial_paths
    end

    it "duplicates .options" do
      stub(Scraper).options { { test: [] } }
      assert_equal Scraper.options, subclass.options
      refute_same Scraper.options, subclass.options
      refute_same Scraper.options[:test], subclass.options[:test]
    end

    it "duplicates .html_filters" do
      assert_equal Scraper.html_filters, subclass.html_filters
      refute_same Scraper.html_filters, subclass.html_filters
    end

    it "duplicates .text_filters" do
      assert_equal Scraper.text_filters, subclass.text_filters
      refute_same Scraper.text_filters, subclass.text_filters
    end
  end

  describe ".filters" do
    it "returns the union of .html_filters and .text_filters" do
      stub(Scraper.html_filters).to_a { [1] }
      stub(Scraper.text_filters).to_a { [2] }
      assert_equal [1, 2], Scraper.filters
    end
  end

  describe "#root_path?" do
    it "returns false when .root_path is blank" do
      stub(Scraper).root_path { '' }
      refute scraper.root_path?
    end

    it "returns false when .root_path is '/'" do
      stub(Scraper).root_path { '/' }
      refute scraper.root_path?
    end

    it "returns true when .root_path is '/path'" do
      stub(Scraper).root_path { '/path' }
      assert scraper.root_path?
    end
  end

  describe "#root_url" do
    let :root_url do
      scraper.root_url
    end

    context "when #root_path? is false" do
      before do
        stub(scraper).root_path? { false }
      end

      it "returns a memoized Docs::URL" do
        assert_instance_of Docs::URL, root_url
        assert_same root_url, scraper.root_url
      end

      it "returns the normalized .base_url" do
        stub(Scraper).base_url { 'http://example.com' }
        assert_equal 'http://example.com/', root_url.to_s
      end
    end

    context "when #root_path? is true" do
      before do
        stub(scraper).root_path? { true }
      end

      it "returns a memoized Docs::URL" do
        assert_instance_of Docs::URL, root_url
        assert_same root_url, scraper.root_url
      end

      it "returns .base_url + .root_path" do
        stub(Scraper).base_url { 'http://example.com/path/' }
        stub(Scraper).root_path { '/root' }
        assert_equal 'http://example.com/path/root', root_url.to_s
      end
    end
  end

  describe "#initial_urls" do
    let :initial_urls do
      scraper.initial_urls
    end

    it "returns a frozen, memoized Array" do
      assert_instance_of Array, initial_urls
      assert initial_urls.frozen?
      assert_same initial_urls, scraper.initial_urls
    end

    it "includes the #root_url" do
      assert_includes initial_urls, scraper.root_url.to_s
    end

    it "includes the .initial_paths converted to urls" do
      stub(Scraper).base_url { 'http://example.com/' }
      stub(Scraper).initial_paths { ['one', '/two'] }
      assert_includes initial_urls, 'http://example.com/one'
      assert_includes initial_urls, 'http://example.com/two'
    end
  end

  describe "#build_page" do
    before do
      stub(scraper).handle_response
    end

    it "requires a path" do
      assert_raises ArgumentError do
        scraper.build_page
      end
    end

    context "with a blank path" do
      it "requests the root url" do
        mock(scraper).request_one(scraper.root_url.to_s)
        scraper.build_page ''
      end
    end

    context "with '/'" do
      it "requests the root url" do
        mock(scraper).request_one(scraper.root_url.to_s)
        scraper.build_page '/'
      end
    end

    context "with '/file'" do
      it "requests 'example.com/file' when the base url is 'example.com" do
        stub(Scraper).base_url { 'http://example.com' }
        mock(scraper).request_one 'http://example.com/file'
        scraper.build_page '/file'
      end

      it "requests 'example.com/file' when the base url is 'example.com/" do
        stub(Scraper).base_url { 'http://example.com/' }
        mock(scraper).request_one 'http://example.com/file'
        scraper.build_page '/file'
      end
    end

    it "returns the processed response" do
      stub(scraper).request_one { response }
      mock(scraper).handle_response(response) { 'test' }
      assert_equal 'test', scraper.build_page('')
    end

    it "yields the processed response" do
      stub(scraper).request_one { response }
      stub(scraper).handle_response(response) { 'test' }
      scraper.build_page('') { |arg| @arg = arg }
      assert @arg
      assert_equal 'test', @arg
    end
  end

  describe "#build_pages" do
    let :block do
      Proc.new {}
    end

    let :processed_response do
      Hash.new
    end

    it "requests the #initial_urls" do
      mock(scraper).request_all(scraper.initial_urls)
      scraper.build_pages(&block)
    end

    it "instruments 'running'" do
      stub(scraper).request_all
      scraper.build_pages(&block)
      assert scraper.last_instrumentation
      assert_equal 'running.scraper', scraper.last_instrumentation[:event]
      assert_equal scraper.initial_urls, scraper.last_instrumentation[:payload][:urls]
    end

    context "when the response is processable" do
      before do
        stub(scraper).request_all do |urls, &block|
          urls.each { |url| @next_urls ||= block.call(response) }
        end
        stub(scraper).handle_response(response) { processed_response }
      end

      it "yields the processed response" do
        scraper.build_pages { |arg| @arg = arg }
        assert_same processed_response, @arg
      end

      context "when :internal_urls is empty" do
        before do
          processed_response[:internal_urls] = []
        end

        it "requests nothing more" do
          scraper.build_pages(&block)
          assert_nil @next_urls
        end

        it "doesn't instrument 'queued'" do
          scraper.build_pages(&block)
          refute_equal 'queued.scraper', scraper.last_instrumentation.try(:[], :event)
        end
      end

      context "when :internal_urls isn't empty" do
        let :internal_urls do
          ['Url']
        end

        before do
          processed_response[:internal_urls] = internal_urls
        end

        it "requests the urls" do
          scraper.build_pages(&block)
          assert_equal internal_urls, @next_urls
        end

        it "doesn't request the same url twice irrespective of case" do
          processed_response[:internal_urls] = scraper.initial_urls.map(&:swapcase)
          scraper.build_pages(&block)
          assert_empty @next_urls
        end

        it "instruments 'queued'" do
          scraper.build_pages(&block)
          assert scraper.last_instrumentation
          assert_equal 'queued.scraper', scraper.last_instrumentation[:event]
          assert_equal internal_urls, scraper.last_instrumentation[:payload][:urls]
        end
      end
    end

    context "when the response isn't processable" do
      it "doesn't yield" do
        stub(scraper).request_all.yields(response)
        stub(scraper).handle_response(response) { nil }
        scraper.build_pages { @yield = true }
        refute @yield
      end
    end
  end

  describe "#options" do
    let :options do
      Hash.new
    end

    let :result do
      scraper.options
    end

    before do
      stub(Scraper).options { options }
    end

    it "returns a frozen, memoized Hash" do
      assert_instance_of Hash, result
      assert result.frozen?
      assert_same result, scraper.options
    end

    it "includes .options" do
      options[:test] = true
      assert result[:test]
    end

    it "includes #base_url" do
      assert_equal scraper.base_url, result[:base_url]
    end

    it "includes #root_url" do
      assert_equal scraper.root_url, result[:root_url]
    end

    it "includes #root_path" do
      assert_equal '/root', result[:root_path]
    end

    it "includes #initial_paths" do
      assert_equal ['/initial'], result[:initial_paths]
    end

    it "adds #initial_paths to :only when it is an array" do
      options[:only] = ['/path']
      assert_includes result[:only], options[:only].first
      assert_includes result[:only], '/initial'
    end

    it "adds #initial_paths to :only when :only_patterns is an array" do
      options[:only_patterns] = []
      assert_includes result[:only], '/initial'
    end

    it "doesn't modify :only in place" do
      options[:only] = []
      result
      assert_empty options[:only]
    end

    context "when #root_path? is false" do
      before do
        stub(scraper).root_path? { false }
      end

      it "doesn't modify :skip" do
        options[:skip] = []
        assert_equal options[:skip], result[:skip]
      end

      it "adds '' and '/' to :only when it is an array" do
        options[:only] = ['/path']
        assert_includes result[:only], options[:only].first
        assert_includes result[:only], ''
        assert_includes result[:only], '/'
      end

      it "adds '' and '/' to :only when :only_patterns is an array" do
        options[:only_patterns] = []
        assert_includes result[:only], ''
        assert_includes result[:only], '/'
      end

      it "doesn't modify :only in place" do
        options[:only] = []
        result
        assert_empty options[:only]
      end
    end

    context "when #root_path? is true" do
      before do
        stub(scraper).root_path? { true }
      end

      it "adds '' and '/' to :skip when it is nil" do
        assert_includes result[:skip], ''
        assert_includes result[:skip], '/'
      end

      it "adds '' and '/' to :skip when it is an array" do
        options[:skip] = ['/path']
        assert_includes result[:skip], options[:skip].first
        assert_includes result[:skip], ''
        assert_includes result[:skip], '/'
      end

      it "doesn't modify :skip in place" do
        options[:skip] = []
        result
        assert_empty options[:skip]
      end

      it "adds #root_path to :only when it is an array" do
        options[:only] = ['/path']
        assert_includes result[:only], options[:only].first
        assert_includes result[:only], '/root'
      end

      it "adds #root_path to :only when :only_patterns is an array" do
        options[:only_patterns] = []
        assert_includes result[:only], '/root'
      end
    end
  end

  describe "#handle_response" do
    let :result do
      scraper.send :handle_response, response
    end

    context "when the response is processable" do
      before do
        stub(scraper).process_response?(response) { true }
      end

      it "runs the pipeline" do
        mock(scraper.pipeline).call.with_any_args
        result
      end

      it "returns the result" do
        stub(scraper.pipeline).call { |_, _, result| result[:test] = true }
        assert result[:test]
      end

      it "instruments 'process_response'" do
        result
        assert scraper.last_instrumentation
        assert_equal 'process_response.scraper', scraper.last_instrumentation[:event]
        assert_equal response, scraper.last_instrumentation[:payload][:response]
      end

      context "the pipeline document" do
        it "is the parsed response body" do
          response.body = 'body'
          stub(scraper.pipeline).call { |arg| @arg = arg }
          mock.proxy(Docs::Parser).new('body') { |parser| stub(parser).html { 'html' } }
          result
          assert_equal 'html', @arg
        end
      end

      context "the pipeline context" do
        let :context do
          stub(scraper.pipeline).call { |_, arg| @arg = arg }
          result
          @arg
        end

        it "includes #options" do
          stub(scraper).options { { test: true } }
          assert context[:test]
        end

        it "includes the response url" do
          response.url = 'url'
          assert_equal 'url', context[:url]
        end
      end
    end

    context "when the response isn't processable" do
      before do
        stub(scraper).process_response?(response) { false }
      end

      it "doesn't run the pipeline" do
        dont_allow(scraper.pipeline).call
        result
      end

      it "returns nil" do
        assert_nil result
      end

      it "instruments 'ignore_response'" do
        result
        assert scraper.last_instrumentation
        assert_equal 'ignore_response.scraper', scraper.last_instrumentation[:event]
        assert_equal response, scraper.last_instrumentation[:payload][:response]
      end
    end
  end

  describe "#pipeline" do
    let :pipeline do
      scraper.pipeline
    end

    it "returns a memoized HTML::Pipeline" do
      assert_instance_of ::HTML::Pipeline, pipeline
      assert_same pipeline, scraper.pipeline
    end

    it "returns a pipeline with the filters stored in .filters" do
      stub(Scraper).filters { [1] }
      assert_equal Scraper.filters, pipeline.filters
    end

    it "returns a pipeline with Docs as instrumentation service" do
      assert_equal Docs, pipeline.instrumentation_service
    end
  end
end
