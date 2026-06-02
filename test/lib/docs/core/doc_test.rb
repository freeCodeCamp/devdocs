require_relative '../../../test_helper'
require_relative '../../../../lib/docs'
require 'base64'

class DocsDocTest < Minitest::Spec
  let :doc do
    Class.new Docs::Doc do
      self.name = 'name'
      self.type = 'type'
    end
  end

  let :page do
    { path: 'path', store_path: 'store_path', output: 'output', entries: [entry] }
  end

  let :entry do
    Docs::Entry.new 'name', 'path', 'type'
  end

  let :store do
    Docs::NullStore.new
  end

  describe ".inherited" do
    it "sets .type" do
      assert_equal doc.type, Class.new(doc).type
    end
  end

  describe ".name" do
    it "returns 'Doc' when the class is Docs::Doc" do
      assert_equal 'Doc', Docs::Doc.name
    end
  end

  describe ".name=" do
    it "stores .name" do
      doc.name = 'test'
      assert_equal 'test', doc.name
    end
  end

  describe ".slug" do
    it "returns 'doc' when the class is Docs::Doc" do
      assert_equal 'doc', Docs::Doc.slug
    end

    it "returns 'doc~4.2_lts' when the class is Docs::Doc and its #version is '42 LTS'" do
      stub(Docs::Doc).version { '4.2 LTS' }
      assert_equal 'doc~4.2_lts', Docs::Doc.slug
    end

    it "returns 'foo~42' when #slug has been set to 'foo' and #version to '42'" do
      doc.slug = 'foo'
      doc.version = '42'
      assert_equal 'foo~42', doc.slug
    end

    it "returns 'foobar' when #name has been set to 'FooBar'" do
      doc.name = 'FooBar'
      assert_equal 'foobar', doc.slug
    end

    it "raises error when #name has unsluggable characters" do
      assert_raises do
        doc.name = 'Foo-Bar'
        doc.slug
      end
    end
  end

  describe ".slug=" do
    it "stores .slug" do
      doc.slug = 'test'
      assert_equal 'test', doc.slug
    end
  end

  describe ".version=" do
    it "stores .version as a string" do
      doc.version = 4815162342
      assert_equal '4815162342', doc.version
    end
  end

  describe ".release=" do
    it "stores .release" do
      doc.release = '1'
      assert_equal '1', doc.release
    end
  end

  describe ".links=" do
    it "stores .links" do
      doc.links = { test: true }
      assert_equal({ test: true }, doc.links)
    end
  end

  describe ".abstract" do
    it "returns nil" do
      assert_nil doc.abstract
    end
  end

  describe ".abstract=" do
    it "stores .abstract" do
      doc.abstract = true
      assert doc.abstract
    end
  end

  describe ".path" do
    it "returns .slug" do
      doc.slug = 'slug'
      assert_equal 'slug', doc.path
    end
  end

  describe ".index_path" do
    it "returns .path + ::INDEX_FILENAME" do
      stub(doc).path { 'path' }
      assert_equal File.join('path', Docs::Doc::INDEX_FILENAME), doc.index_path
    end
  end

  describe ".db_path" do
    it "returns .path + ::DB_FILENAME" do
      stub(doc).path { 'path' }
      assert_equal File.join('path', Docs::Doc::DB_FILENAME), doc.db_path
    end
  end

  describe ".meta_path" do
    it "returns .path + ::META_FILENAME" do
      stub(doc).path { 'path' }
      assert_equal File.join('path', Docs::Doc::META_FILENAME), doc.meta_path
    end
  end

  describe ".new" do
    it "raises an error when .abstract is true" do
      doc.abstract = true
      assert_raises NotImplementedError do
        doc.new
      end
    end
  end

  describe ".as_json" do
    it "returns a hash" do
      assert_instance_of Hash, doc.as_json
    end

    it "includes the doc's name, slug, type, version, and release" do
      assert_equal %i(name slug type), doc.as_json.keys

      %w(name slug type version release links).each do |attribute|
        eval "stub(doc).#{attribute} { attribute }"
        assert_equal attribute, doc.as_json[attribute.to_sym]
      end
    end

    it "includes the doc's version when it's defined and nil" do
      refute doc.as_json.key?(:version)
      doc.version = nil
      assert doc.as_json.key?(:version)
    end
  end

  describe ".store_page" do
    it "builds a page" do
      any_instance_of(doc) do |instance|
        stub(instance).build_page('id') { @called = true; nil }
      end
      doc.store_page(store, 'id') {}
      assert @called
    end

    context "when the page builds successfully" do
      before do
        any_instance_of(doc) do |instance|
          stub(instance).build_page { page }
        end
      end

      context "and it has :entries" do
        it "returns true" do
          assert doc.store_page(store, 'id')
        end

        it "stores a file" do
          mock(store).write(page[:store_path], page[:output])
          doc.store_page(store, 'id')
        end

        it "opens the .path directory before storing the file" do
          stub(doc).path { 'path' }
          stub(store).write { assert false }
          mock(store).open('path') do |_, &block|
            stub(store).write
            block.call
          end
          doc.store_page(store, 'id')
        end
      end

      context "and it doesn't have :entries" do
        before do
          page[:entries] = []
        end

        it "returns false" do
          refute doc.store_page(store, 'id')
        end

        it "doesn't store a file" do
          dont_allow(store).write
          doc.store_page(store, 'id')
        end
      end
    end

    context "when the page doesn't build successfully" do
      before do
        any_instance_of(doc) do |instance|
          stub(instance).build_page { nil }
        end
      end

      it "returns false" do
        refute doc.store_page(store, 'id')
      end

      it "doesn't store a file" do
        dont_allow(store).write
        doc.store_page(store, 'id')
      end
    end

    context "when the store can't be opened" do
      before do
        stub(store).open { raise Docs::SetupError, "oh no" }
      end

      it "logs an error" do
        output = capture_io { doc.store_page(store, 'id') }.first
        
        assert_match "ERROR: oh no", output
      end
    end
  end

  describe ".store_pages" do
    it "build the pages" do
      any_instance_of(doc) do |instance|
        stub(instance).build_pages { @called = true }
      end
      doc.store_pages(store) {}
      assert @called
    end

    context "when pages are built successfully" do
      let :pages do
        [
          page.deep_dup.tap { |p| page[:entries].first.tap { |e| e.name = 'one' } },
          page.deep_dup.tap { |p| page[:entries].first.tap { |e| e.name = 'two' } }
        ]
      end

      before do
        any_instance_of(doc) do |instance|
          stub(instance).build_pages { |&block| pages.each(&block) }
        end
      end

      context "and at least one page has :entries" do
        it "returns true" do
          assert doc.store_pages(store)
        end

        it "stores a file for each page that has :entries" do
          pages.first.merge!(entries: [], output: '')
          mock(store).write(page[:store_path], page[:output])
          mock(store).write('index.json', anything)
          mock(store).write('db.json', anything)
          mock(store).write('meta.json', anything)
          doc.store_pages(store)
        end

        it "stores an index that contains all the pages' entries" do
          stub(store).write(page[:store_path], page[:output])
          stub(store).write('db.json', anything)
          stub(store).write('meta.json', anything)
          mock(store).write('index.json', anything) do |path, json|
            json = JSON.parse(json)
            assert_equal pages.length, json['entries'].length
            assert_includes json['entries'], Docs::Entry.new('one', 'path', 'type').as_json.stringify_keys
          end
          doc.store_pages(store)
        end

        it "stores a db that contains all the pages, indexed by path" do
          stub(store).write(page[:store_path], page[:output])
          stub(store).write('index.json', anything)
          stub(store).write('meta.json', anything)
          mock(store).write('db.json', anything) do |path, json|
            json = JSON.parse(json)
            assert_equal page[:output], json[page[:path]]
          end
          doc.store_pages(store)
        end

        it "stores a meta file that contains the doc's metadata" do
          stub(store).write(page[:store_path], page[:output])
          stub(store).write('index.json', anything)
          stub(store).write('db.json', anything)
          mock(store).write('meta.json', anything) do |path, json|
            json = JSON.parse(json)
            assert_equal %w(name slug type mtime db_size).sort, json.keys.sort
          end
          doc.store_pages(store)
        end

        it "replaces the .path directory before storing the files" do
          stub(doc).path { 'path' }
          stub(store).write { assert false }
          mock(store).replace('path') do |_, &block|
            stub(store).write
            block.call
          end
          doc.store_pages(store)
        end
      end

      context "and no pages have :entries" do
        before do
          pages.each { |page| page[:entries] = [] }
        end

        it "returns false" do
          refute doc.store_pages(store)
        end

        it "doesn't store files" do
          dont_allow(store).write
          doc.store_pages(store)
        end
      end
    end

    context "when no pages are built successfully" do
      before do
        any_instance_of(doc) do |instance|
          stub(instance).build_pages
        end
      end

      it "returns false" do
        refute doc.store_pages(store)
      end

      it "doesn't store files" do
        dont_allow(store).write
        doc.store_pages(store)
      end
    end

    context "when the store can't be opened" do
      before do
        stub(store).replace { raise Docs::SetupError, "oh no" }
      end

      it "logs an error" do
        output = capture_io { doc.store_pages(store) }.first
        
        assert_match "ERROR: oh no", output
      end
    end
  end

  describe ".versions" do
    it "returns [self] if no versions have been created" do
      assert_equal [doc], doc.versions
    end
  end

  describe ".version" do
    context "with no args" do
      it "returns @version by default" do
        doc.version = 'v'
        assert_equal 'v', doc.version
      end
    end

    context "with args" do
      it "creates a version subclass" do
        version = doc.version('4') { self.release = '8'; self.links = ["https://#{self.version}"] }

        assert_equal [version], doc.versions

        assert_nil doc.version
        assert_nil doc.release
        refute doc.version?

        assert version.version?
        assert_equal '4', version.version
        assert_equal '8', version.release
        assert_equal 'name', version.name
        assert_equal 'type', version.type
        assert_equal ['https://4'], version.links
      end
    end

    it "compares versions" do
      instance = doc.versions.first.new
      assert_equal "Up-to-date", instance.outdated_state('0.0.2', '0.0.3')
      assert_equal "Outdated major version", instance.outdated_state('0.2', '0.3')
      assert_equal 'Up-to-date', instance.outdated_state('1', '1')
      assert_equal 'Up-to-date', instance.outdated_state('1.2', '1.2')
      assert_equal 'Up-to-date', instance.outdated_state('1.2.2', '1.2.2')
      assert_equal 'Up-to-date', instance.outdated_state('1.2.2', '1.2.3')
      assert_equal "Outdated major version", instance.outdated_state('1', '2')
      assert_equal "Up-to-date", instance.outdated_state('1.0.2', '1.0.3')
      assert_equal "Outdated major version", instance.outdated_state('1.2', '1.3')
      assert_equal "Outdated minor version", instance.outdated_state('2.2', '2.3')
      assert_equal "Outdated major version", instance.outdated_state('9', '10')
      assert_equal "Outdated major version", instance.outdated_state('99', '101')
      assert_equal 'Up-to-date', instance.outdated_state('2006-01-02', '2006-01-03')
      assert_equal "Outdated minor version", instance.outdated_state('2006-01-02', '2006-02-03')
    end
  end

  # PRIVATE CLASS METHODS

  describe ".default_slug" do
    it "returns name.downcase when name is alphanumeric" do
      doc.name = 'FooBar'
      assert_equal 'foobar', doc.send(:default_slug)
    end

    it "returns name.downcase when name contains underscores" do
      doc.name = 'Foo_Bar'
      assert_equal 'foo_bar', doc.send(:default_slug)
    end

    it "returns nil when name contains a hyphen" do
      doc.name = 'Foo-Bar'
      assert_nil doc.send(:default_slug)
    end

    it "returns nil when name contains a space" do
      doc.name = 'Foo Bar'
      assert_nil doc.send(:default_slug)
    end

    it "returns nil when name contains a dot" do
      doc.name = 'Foo.Bar'
      assert_nil doc.send(:default_slug)
    end
  end

  describe ".store_page?" do
    it "returns true when page has non-empty :entries" do
      assert doc.send(:store_page?, page)
    end

    it "returns false when page has empty :entries" do
      refute doc.send(:store_page?, page.merge(entries: []))
    end

    it "returns false when page has nil :entries" do
      refute doc.send(:store_page?, page.merge(entries: nil))
    end
  end

  describe ".store_index" do
    let :index do
      obj = Object.new
      stub(obj).to_json { '{"entries":[]}' }
      obj
    end

    context "when read_write is true (default)" do
      it "reads old JSON from store" do
        mock(store).read('index.json') { '{}' }
        stub(store).write
        doc.send(:store_index, store, 'index.json', index)
      end

      it "writes new JSON to store" do
        stub(store).read { '{}' }
        mock(store).write('index.json', '{"entries":[]}')
        doc.send(:store_index, store, 'index.json', index)
      end
    end

    context "when read_write is false" do
      it "doesn't read from store" do
        dont_allow(store).read
        doc.send(:store_index, store, 'index.json', index, false)
      end

      it "doesn't write to store" do
        dont_allow(store).write
        doc.send(:store_index, store, 'index.json', index, false)
      end
    end
  end

  describe ".store_meta" do
    it "writes to META_FILENAME" do
      stub(store).size { 0 }
      mock(store).write(Docs::Doc::META_FILENAME, anything)
      doc.send(:store_meta, store)
    end

    it "includes :mtime as an integer in the written JSON" do
      stub(store).size { 0 }
      stub(store).write(Docs::Doc::META_FILENAME, anything) do |_, json|
        @json = JSON.parse(json)
      end
      doc.send(:store_meta, store)
      assert @json.key?('mtime')
      assert_instance_of Integer, @json['mtime']
    end

    it "includes :db_size from the store" do
      stub(store).size(Docs::Doc::DB_FILENAME) { 42 }
      stub(store).write(Docs::Doc::META_FILENAME, anything) do |_, json|
        @json = JSON.parse(json)
      end
      doc.send(:store_meta, store)
      assert_equal 42, @json['db_size']
    end
  end

  # PRIVATE INSTANCE METHODS

  describe "#fetch" do
    let :instance do
      doc.new
    end

    let :logger do
      l = Object.new
      stub(l).debug
      stub(l).error
      l
    end

    let :opts do
      { logger: logger }
    end

    let :response do
      r = Object.new
      stub(r).success? { true }
      stub(r).body { 'body' }
      r
    end

    before do
      stub(Docs::Request).run { response }
    end

    it "returns the response body on success" do
      assert_equal 'body', instance.send(:fetch, 'http://example.com/', opts)
    end

    it "calls Request.run with the given url" do
      mock(Docs::Request).run('http://example.com/', anything) { response }
      instance.send(:fetch, 'http://example.com/', opts)
    end

    it "adds Authorization header when opts has :github_token and url is GitHub API" do
      opts[:github_token] = 'mytoken'
      mock(Docs::Request).run(anything, anything) do |_, request_opts|
        assert_equal 'token mytoken', request_opts[:headers]['Authorization']
        response
      end
      instance.send(:fetch, 'https://api.github.com/repos', opts)
    end

    it "doesn't add Authorization header for non-GitHub API urls even with :github_token" do
      opts[:github_token] = 'mytoken'
      mock(Docs::Request).run(anything, anything) do |_, request_opts|
        refute request_opts[:headers].key?('Authorization')
        response
      end
      instance.send(:fetch, 'http://example.com/', opts)
    end

    context "when response is unsuccessful" do
      before do
        stub(response).success? { false }
        stub(response).timed_out? { false }
        stub(response).code { 404 }
      end

      it "raises an error" do
        assert_raises(RuntimeError) do
          instance.send(:fetch, 'http://example.com/', opts)
        end
      end

      it "includes the response code in the error message" do
        err = assert_raises(RuntimeError) { instance.send(:fetch, 'http://example.com/', opts) }
        assert_match '404', err.message
      end
    end

    context "when response times out" do
      before do
        stub(response).success? { false }
        stub(response).timed_out? { true }
      end

      it "raises an error with a timeout message" do
        err = assert_raises(RuntimeError) { instance.send(:fetch, 'http://example.com/', opts) }
        assert_match 'Timed out', err.message
      end
    end
  end

  describe "#fetch_doc" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "returns a Nokogiri::HTML::Document" do
      stub(instance).fetch { '<html><body></body></html>' }
      assert_instance_of Nokogiri::HTML::Document, instance.send(:fetch_doc, 'http://example.com/', opts)
    end

    it "fetches the given url" do
      mock(instance).fetch('http://example.com/', opts) { '<html></html>' }
      instance.send(:fetch_doc, 'http://example.com/', opts)
    end
  end

  describe "#fetch_json" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "returns parsed JSON" do
      stub(instance).fetch { '{"key":"value"}' }
      assert_equal({ 'key' => 'value' }, instance.send(:fetch_json, 'http://example.com/', opts))
    end

    it "fetches the given url" do
      mock(instance).fetch('http://example.com/', opts) { '{}' }
      instance.send(:fetch_json, 'http://example.com/', opts)
    end
  end

  describe "#get_npm_version" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "returns the 'latest' dist-tag by default" do
      stub(instance).fetch_json { { 'dist-tags' => { 'latest' => '1.2.3' } } }
      assert_equal '1.2.3', instance.send(:get_npm_version, 'some-package', opts)
    end

    it "returns a specific dist-tag when given" do
      stub(instance).fetch_json { { 'dist-tags' => { 'next' => '2.0.0-beta' } } }
      assert_equal '2.0.0-beta', instance.send(:get_npm_version, 'some-package', opts, 'next')
    end

    it "fetches from the npm registry URL" do
      mock(instance).fetch_json('https://registry.npmjs.com/some-package', opts) { { 'dist-tags' => { 'latest' => '1.0.0' } } }
      instance.send(:get_npm_version, 'some-package', opts)
    end
  end

  describe "#get_latest_github_release" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "strips a leading 'v' from the tag name" do
      stub(instance).fetch_json { { 'tag_name' => 'v1.2.3' } }
      assert_equal '1.2.3', instance.send(:get_latest_github_release, 'owner', 'repo', opts)
    end

    it "returns the tag name unchanged when it doesn't start with 'v'" do
      stub(instance).fetch_json { { 'tag_name' => '1.2.3' } }
      assert_equal '1.2.3', instance.send(:get_latest_github_release, 'owner', 'repo', opts)
    end

    it "fetches from the correct GitHub releases URL" do
      mock(instance).fetch_json('https://api.github.com/repos/owner/repo/releases/latest', opts) { { 'tag_name' => '1.0.0' } }
      instance.send(:get_latest_github_release, 'owner', 'repo', opts)
    end
  end

  describe "#get_github_tags" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "fetches from the correct GitHub tags URL" do
      mock(instance).fetch_json('https://api.github.com/repos/owner/repo/tags', opts) { [] }
      instance.send(:get_github_tags, 'owner', 'repo', opts)
    end

    it "returns the tags list" do
      tags = [{ 'name' => 'v1.0' }]
      stub(instance).fetch_json { tags }
      assert_equal tags, instance.send(:get_github_tags, 'owner', 'repo', opts)
    end
  end

  describe "#get_github_file_contents" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "returns Base64-decoded file contents" do
      stub(instance).fetch_json { { 'content' => ::Base64.encode64('hello world') } }
      assert_equal 'hello world', instance.send(:get_github_file_contents, 'owner', 'repo', 'README.md', opts)
    end

    it "fetches from the correct GitHub contents URL" do
      mock(instance).fetch_json('https://api.github.com/repos/owner/repo/contents/README.md', opts) { { 'content' => ::Base64.encode64('') } }
      instance.send(:get_github_file_contents, 'owner', 'repo', 'README.md', opts)
    end
  end

  describe "#get_latest_github_commit_date" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "returns the epoch timestamp of the latest commit" do
      date_str = '2023-06-15T12:00:00Z'
      commits = [{ 'commit' => { 'author' => { 'date' => date_str } } }]
      stub(instance).fetch_json { commits }
      assert_equal Date.iso8601(date_str).to_time.to_i, instance.send(:get_latest_github_commit_date, 'owner', 'repo', opts)
    end

    it "fetches from the correct GitHub commits URL" do
      date_str = '2023-06-15T12:00:00Z'
      commits = [{ 'commit' => { 'author' => { 'date' => date_str } } }]
      mock(instance).fetch_json('https://api.github.com/repos/owner/repo/commits', opts) { commits }
      instance.send(:get_latest_github_commit_date, 'owner', 'repo', opts)
    end
  end

  describe "#get_gitlab_tags" do
    let :instance do
      doc.new
    end

    let :opts do
      { logger: nil }
    end

    it "fetches from the correct GitLab tags URL" do
      mock(instance).fetch_json('https://gitlab.example.com/api/v4/projects/group%2Fproject/repository/tags', opts) { [] }
      instance.send(:get_gitlab_tags, 'gitlab.example.com', 'group', 'project', opts)
    end

    it "returns the tags list" do
      tags = [{ 'name' => 'v1.0' }]
      stub(instance).fetch_json { tags }
      assert_equal tags, instance.send(:get_gitlab_tags, 'gitlab.example.com', 'group', 'project', opts)
    end
  end
end
