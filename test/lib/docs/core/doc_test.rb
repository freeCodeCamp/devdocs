require 'test_helper'
require 'docs'

class DocsDocTest < MiniTest::Spec
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
          mock(store).open('path') do |_, block|
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
          stub(instance).build_pages { |block| pages.each(&block) }
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
          mock(store).replace('path') do |_, block|
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
  end
end
