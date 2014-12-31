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
    Docs::Entry.new
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
  end

  describe ".slug=" do
    it "stores .slug" do
      doc.slug = 'test'
      assert_equal 'test', doc.slug
    end
  end

  describe ".version=" do
    it "stores .version" do
      doc.version = '1'
      assert_equal '1', doc.version
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

    it "includes the doc's name, slug, type, version, index_path and db_path" do
      %w(name slug type version index_path db_path).each do |attribute|
        eval "stub(doc).#{attribute} { attribute }"
        assert_equal attribute, doc.as_json[attribute.to_sym]
      end
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
        [page.dup, page.dup]
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
          doc.store_pages(store)
        end

        it "stores an index that contains all the pages' entries" do
          stub(store).write(page[:store_path], page[:output])
          stub(store).write('db.json', anything)
          mock(store).write('index.json', anything) do |path, json|
            json = JSON.parse(json)
            assert_equal pages.length, json['entries'].length
            assert_includes json['entries'], entry.as_json.stringify_keys
          end
          doc.store_pages(store)
        end

        it "stores a db that contains all the pages, indexed by path" do
          stub(store).write(page[:store_path], page[:output])
          stub(store).write('index.json', anything)
          mock(store).write('db.json', anything) do |path, json|
            json = JSON.parse(json)
            assert_equal page[:output], json[page[:path]]
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
end
