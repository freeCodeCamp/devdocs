require 'test_helper'
require 'docs'

class InternalUrlsFilterTest < MiniTest::Spec
  include FilterTestHelper
  self.filter_class = Docs::InternalUrlsFilter

  before do
    context[:base_url] = context[:root_url] = context[:url] = 'http://example.com/dir'
  end

  let :internal_urls do
    filter_result[:internal_urls]
  end

  describe ":internal_urls" do
    it "is an array" do
      assert_instance_of Array, internal_urls
    end

    it "includes urls contained in the base url" do
      @body = link_to(url = 'http://example.com/dir/path')
      assert_includes internal_urls, url
    end

    it "doesn't include urls not contained in the base url" do
      @body = link_to 'http://example.com/dir-2/path'
      assert_empty internal_urls
    end

    it "includes urls irrespective of case" do
      context[:base_url] = 'http://example.com/Dir'
      @body = link_to 'HTTP://example.com/diR/path'
      assert_equal 1, internal_urls.length
    end

    it "doesn't include relative urls" do
      @body = link_to 'http'
      assert_empty internal_urls
    end

    it "doesn't include ftp urls" do
      @body = link_to 'ftp://example.com/dir/path'
      assert_empty internal_urls
    end

    it "doesn't include invalid urls" do
      @body = link_to 'http://example.com/dir/%path'
      assert_empty internal_urls
    end

    it "retains query strings" do
      @body = link_to(url = 'http://example.com/dir?query')
      assert_includes internal_urls, url
    end

    it "removes fragments" do
      @body = link_to 'http://example.com/dir#frag'
      assert_includes internal_urls, 'http://example.com/dir'
    end

    it "doesn't have duplicates" do
      @body = link_to('http://example.com/dir/path') * 2
      assert_equal 1, internal_urls.length
    end

    it "normalizes the urls" do
      @body = link_to(url = 'HTTP://EXAMPLE.COM/dir')
      assert_includes internal_urls, url.downcase
    end

    it "doesn't include urls included in context[:skip]" do
      context[:skip] = ['/path']
      @body = link_to 'http://example.com/dir/Path'
      assert_empty internal_urls
    end

    it "doesn't include urls matching context[:skip_patterns]" do
      context[:skip_patterns] = [/\A\/path.*/]
      @body = link_to 'http://example.com/dir/path.html'
      assert_empty internal_urls
    end

    it "includes urls that don't match context[:skip_patterns]" do
      context[:skip_patterns] = [/\A\/path.*/]
      @body = link_to(url = 'http://example.com/dir/file')
      assert_includes internal_urls, url
    end

    it "includes urls included in context[:only]" do
      context[:only] = ['/path']
      @body = link_to(url = 'http://example.com/dir/Path')
      assert_includes internal_urls, url
    end

    it "doesn't include urls not included in context[:only]" do
      context[:only] = []
      @body = link_to 'http://example.com/dir/Path'
      assert_empty internal_urls
    end

    it "includes urls matching context[:only_patterns]" do
      context[:only_patterns] = [/file/]
      @body = link_to(url = 'http://example.com/dir/file')
      assert_includes internal_urls, url
    end

    it "doesn't include urls that don't match context[:only_patterns]" do
      context[:only_patterns] = []
      @body = link_to 'http://example.com/dir/file'
      assert_empty internal_urls
    end
  end

  context "when the base url is 'example.com'" do
    before do
      context[:base_url] = 'http://example.com'
      context[:root_url] = 'http://example.com/'
    end

    context "and the url is 'example.com/file'" do
      before { context[:url] = 'http://example.com/file' }

      it "replaces 'example.com' with '.'" do
        @body = link_to 'http://example.com'
        assert_equal link_to('.'), filter_output_string
      end

      it "replaces 'example.com/' with '.'" do
        @body = link_to 'http://example.com/'
        assert_equal link_to('.'), filter_output_string
      end

      it "replaces 'example.com/test' with 'test'" do
        @body = link_to 'http://example.com/test'
        assert_equal link_to('test'), filter_output_string
      end

      it "replaces 'example.com/test/' with 'test/'" do
        @body = link_to 'http://example.com/test/'
        assert_equal link_to('test/'), filter_output_string
      end

      it "retains query strings" do
        @body = link_to 'http://example.com/?query'
        assert_equal link_to('.?query'), filter_output_string
      end

      it "retains fragments" do
        @body = link_to 'http://example.com/#frag'
        assert_equal link_to('.#frag'), filter_output_string
      end

      it "doesn't replace 'https://example.com'" do
        @body = link_to 'https://example.com'
        assert_equal @body, filter_output_string
      end

      it "doesn't replace 'http://not.example.com'" do
        @body = link_to 'http://not.example.com'
        assert_equal @body, filter_output_string
      end

      context "and the root url is 'example.com/root/path'" do
        it "replaces 'example.com/root/path' with '.'" do
          context[:root_url] = 'http://example.com/root/path'
          @body = link_to 'http://example.com/root/path'
          assert_equal link_to('.'), filter_output_string
        end
      end
    end
  end

  context "when the base url is 'example.com/dir'" do
    before do
      context[:base_url] = context[:root_url] = 'http://example.com/dir'
    end

    context "and the url is 'example.com/dir'" do
      before { context[:url] = 'http://example.com/dir' }

      it "replaces 'example.com/dir' with '.'" do
        @body = link_to 'http://example.com/dir'
        assert_equal link_to('.'), filter_output_string
      end

      it "replaces 'example.com/dir/' with '.'" do
        @body = link_to 'http://example.com/dir/'
        assert_equal link_to('.'), filter_output_string
      end

      it "replaces 'example.com/dir/test' with 'test'" do
        @body = link_to 'http://example.com/dir/test'
        assert_equal link_to('test'), filter_output_string
      end

      it "doesn't replace 'example.com/'" do
        @body = link_to 'http://example.com/'
        assert_equal @body, filter_output_string
      end
    end

    context "and the url is 'example.com/dir/file'" do
      before { context[:url] = 'http://example.com/dir/file' }

      it "replaces 'example.com/dir' with '.'" do
        @body = link_to 'http://example.com/dir'
        assert_equal link_to('.'), filter_output_string
      end

      it "replaces 'example.com/dir/' with '.'" do
        @body = link_to 'http://example.com/dir/'
        assert_equal link_to('.'), filter_output_string
      end
    end
  end

  context "when the base url is 'example.com/dir/'" do
    before do
      context[:base_url] = context[:root_url] = 'http://example.com/dir/'
    end

    context "and the url is 'example.com/dir/file'" do
      before { context[:url] = 'http://example.com/dir/file' }

      it "replaces 'example.com/dir/' with '.'" do
        @body = link_to 'http://example.com/dir/'
        assert_equal link_to('.'), filter_output_string
      end

      it "doesn't replace 'example.com/dir'" do
        @body = link_to 'http://example.com/dir'
        assert_equal @body, filter_output_string
      end
    end
  end

  context "context[:trailing_slash]" do
    before do
      @body = link_to('http://example.com/dir/path/') + link_to('http://example.com/dir/path')
    end

    context "when it is true" do
      before do
        context[:trailing_slash] = true
      end

      it "adds a trailing slash to :internal_urls" do
        assert_equal ['http://example.com/dir/path/'], internal_urls
      end

      it "adds a trailing slash to replaced urls" do
        assert_equal link_to('path/') * 2, filter_output_string
      end
    end

    context "when it is false" do
      before do
        context[:trailing_slash] = false
      end

      it "removes the trailing slash from :internal_urls" do
        assert_equal ['http://example.com/dir/path'], internal_urls
      end

      it "removes the trailing slash from replaced urls" do
        assert_equal link_to('path') * 2, filter_output_string
      end

      it "doesn't remove the leading slash" do
        url = context[:base_url] = context[:root_url] = 'http://example.com/'
        @body = link_to(url)
        assert_equal [url], internal_urls
      end
    end
  end

  context "context[:skip_links]" do
    before do
      @body = link_to context[:url]
    end

    context "when it is true" do
      before do
        context[:skip_links] = true
      end

      it "doesn't set :internal_urls" do
        refute internal_urls
      end

      it "doesn't replace urls" do
        assert_equal @body, filter_output_string
      end
    end

    context "when it is a block" do
      it "calls the block with the filter instance" do
        context[:skip_links] = ->(arg) { @arg = arg; nil }
        filter.call
        assert_equal filter, @arg
      end

      context "and the block returns true" do
        before do
          context[:skip_links] = ->(_) { true }
        end

        it "doesn't set :internal_urls" do
          refute internal_urls
        end

        it "doesn't replace urls" do
          assert_equal @body, filter_output_string
        end
      end

      context "and the block returns false" do
        before do
          context[:skip_links] = ->(_) { false }
        end

        it "sets :internal_urls" do
          assert internal_urls
        end

        it "replaces urls" do
          refute_equal @body, filter_output_string
        end
      end
    end
  end

  context "context[:follow_links]" do
    before do
      @body = link_to context[:url]
    end

    context "when it is false" do
      before do
        context[:follow_links] = false
      end

      it "doesn't set :internal_urls" do
        refute internal_urls
      end

      it "replaces urls" do
        refute_equal @body, filter_output_string
      end
    end

    context "when it is a block" do
      it "calls the block with the filter instance" do
        context[:follow_links] = ->(arg) { @arg = arg; nil }
        filter.call
        assert_equal filter, @arg
      end

      context "and the block returns false" do
        before do
          context[:follow_links] = ->(_) { false }
        end

        it "doesn't set :internal_urls" do
          refute internal_urls
        end

        it "replaces urls" do
          refute_equal @body, filter_output_string
        end
      end

      context "and the block returns true" do
        before do
          context[:follow_links] = ->(_) { true }
        end

        it "sets :internal_urls" do
          assert internal_urls
        end
      end
    end
  end

  context "context[:skip_link] is a block" do
    before do
      @body = link_to context[:url]
    end

    it "calls the block with each link" do
      context[:skip_link] = ->(arg) { @arg = arg.try(:to_html); nil }
      filter.call
      assert_equal @body, @arg
    end

    context "and the block returns true" do
      before do
        context[:skip_link] = ->(_) { true }
      end

      it "doesn't include the link's url in :internal_urls" do
        assert internal_urls.empty?
      end

      it "doesn't replace the link's url" do
        assert_equal @body, filter_output_string
      end
    end

    context "and the block returns false" do
      before do
        context[:skip_link] = ->(_) { false }
      end

      it "includes the link's url in :internal_urls" do
        refute internal_urls.empty?
      end

      it "replaces the link's url" do
        refute_equal @body, filter_output_string
      end
    end
  end
end
