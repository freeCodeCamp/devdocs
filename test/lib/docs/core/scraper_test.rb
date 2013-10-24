require 'test_helper'
require 'docs'

class DocsScraperTest < MiniTest::Spec
  class Scraper < Docs::Scraper
    self.type = 'scraper'
    self.base_url = 'http://example.com/'
    self.root_path = '/root'
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

  let :processed_response do
    Hash.new
  end

  describe ".inherited" do
    let :subclass do
      Class.new Scraper
    end

    it "sets .type" do
      assert_equal Scraper.type, subclass.type
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
    context "when #root_path? is false" do
      before do
        stub(scraper).root_path? { false }
      end

      it "returns a Docs::URL" do
        assert_instance_of Docs::URL, scraper.root_url
      end

      it "returns the normalized base url" do
        stub(Scraper).base_url { 'http://example.com' }
        assert_equal 'http://example.com/', scraper.root_url.to_s
      end
    end

    context "when .root_path isn't blank" do
      before do
        stub(scraper).root_path? { true }
      end

      it "returns a Docs::URL" do
        assert_instance_of Docs::URL, scraper.root_url
      end

      it "returns base url + root path" do
        stub(Scraper).base_url { 'http://example.com/path/' }
        assert_equal 'http://example.com/path/root', scraper.root_url.to_s
      end
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

    it "requests the root url" do
      mock(scraper).request_all(scraper.root_url.to_s)
      scraper.build_pages(&block)
    end

    it "instruments 'running'" do
      stub(scraper).request_all
      scraper.build_pages(&block)
      assert scraper.last_instrumentation
      assert_equal 'running.scraper', scraper.last_instrumentation[:event]
      assert_includes scraper.last_instrumentation[:payload][:urls], scraper.root_url.to_s
    end

    context "when the response is processable" do
      before do
        stub(scraper).request_all.with_any_args { |*args| @returned = args.last.call(response) }
        stub(scraper).handle_response(response) { processed_response }
      end

      it "yields the processed response" do
        scraper.build_pages { |arg| @arg = arg }
        assert @arg
        assert_equal processed_response, @arg
      end

      context "when response[:internal_urls] is empty" do
        before do
          processed_response[:internal_urls] = []
        end

        it "requests nothing more" do
          scraper.build_pages(&block)
          assert_nil @returned
        end

        it "doesn't instrument 'queued'" do
          scraper.build_pages(&block)
          refute_equal 'queued.scraper', scraper.last_instrumentation.try(:[], :event)
        end
      end

      context "when response[:internal_urls] isn't empty" do
        let :urls do
          ['Url']
        end

        before do
          processed_response[:internal_urls] = urls
        end

        it "requests the urls" do
          scraper.build_pages(&block)
          assert_equal urls, @returned
        end

        it "doesn't request the same url twice irrespective of case" do
          stub(Scraper).root_path { 'PATH' }
          processed_response[:internal_urls] = [scraper.root_url.to_s.swapcase]
          scraper.build_pages(&block)
          assert_empty @returned
        end

        it "instruments 'queued'" do
          scraper.build_pages(&block)
          assert scraper.last_instrumentation
          assert_equal 'queued.scraper', scraper.last_instrumentation[:event]
          assert_equal urls, scraper.last_instrumentation[:payload][:urls]
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
      scraper.options
    end

    it "returns a frozen, memoized Hash" do
      assert_instance_of Hash, options
      assert options.frozen?
      assert_same options, scraper.options
    end

    it "includes .options" do
      stub(Scraper).options { { test: true } }
      assert options[:test]
    end

    it "includes #base_url" do
      assert_equal scraper.base_url, options[:base_url]
    end

    it "includes #root_url" do
      assert_equal scraper.root_url, options[:root_url]
    end

    it "includes .root_path" do
      assert_equal '/root', options[:root_path]
    end

    context "when #root_path? is false" do
      before do
        stub(scraper).root_path? { false }
      end

      it "doesn't modify :skip" do
        assert_nil options[:skip]
      end

      context "and :only is an array" do
        before do
          stub(Scraper).options { { only: ['/path'] } }
        end

        it "adds ['', '/']" do
          assert_includes options[:only], '/path'
          assert_includes options[:only], ''
          assert_includes options[:only], '/'
        end

        it "doesn't modify the array in place" do
          assert_equal ['/path'], Scraper.options[:only]
        end
      end

      context "and :only_patterns is an array" do
        it "assigns ['', '/'] to :only" do
          stub(Scraper).options { { only_patterns: [] } }
          assert_equal ['', '/'], options[:only]
        end
      end
    end

    context "when #root_path? is true" do
      before do
        stub(scraper).root_path? { true }
      end

      context "and :skip is nil" do
        it "assigns it ['', '/']" do
          assert_equal ['', '/'], options[:skip]
        end
      end

      context "and :skip is an array" do
        before do
          stub(Scraper).options { { skip: ['/path'] } }
        end

        it "adds ['', '/']" do
          assert_includes options[:skip], '/path'
          assert_includes options[:skip], ''
          assert_includes options[:skip], '/'
        end

        it "doesn't modify the array in place" do
          assert_equal ['/path'], Scraper.options[:skip]
        end
      end

      context "and :only is an array" do
        it "adds .root_path" do
          stub(Scraper).options { { only: [] } }
          assert_includes options[:only], '/root'
        end
      end

      context "and :only_patterns is an array" do
        it "assigns [.root_path] to :only" do
          stub(Scraper).options { { only_patterns: [] } }
          assert_equal ['/root'], options[:only]
        end
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
    it "returns an HTML::Pipeline with .filters" do
      stub(Scraper).filters { [1] }
      assert_instance_of ::HTML::Pipeline, scraper.pipeline
      assert_equal Scraper.filters, scraper.pipeline.filters
    end

    it "is memoized" do
      assert_same scraper.pipeline, scraper.pipeline
    end

    it "assigns Docs as the pipeline's instrumentation service" do
      assert_equal Docs, scraper.pipeline.instrumentation_service
    end
  end
end
