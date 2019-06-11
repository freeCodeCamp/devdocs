require 'test_helper'
require 'docs'

class ManifestTest < MiniTest::Spec
  let :doc do
    doc = Class.new Docs::Doc
    doc.name = 'TestDoc'
    doc
  end

  let :store do
    Docs::NullStore.new
  end

  let :manifest do
    Docs::Manifest.new store, [doc]
  end

  describe "#store" do
    before do
      stub(manifest).as_json
    end

    it "stores a file" do
      mock(store).write.with_any_args
      manifest.store
    end

    describe "the file" do
      it "is named ::FILENAME" do
        mock(store).write Docs::Manifest::FILENAME, anything
        manifest.store
      end

      it "contains the manifest's JSON dump" do
        stub(manifest).to_json { 'json' }
        mock(store).write anything, 'json'
        manifest.store
      end
    end
  end

  describe "#as_json" do
    let :meta_path do
      'meta_path'
    end

    before do
      stub(doc).meta_path { meta_path }
    end

    it "returns an array" do
      manifest = Docs::Manifest.new store, []
      assert_instance_of Array, manifest.as_json
    end

    context "when the doc has a meta file" do
      before do
        stub(store).exist?(meta_path) { true }
        stub(store).read(meta_path) { '{"name":"Test"}' }
      end

      it "includes the doc's meta representation" do
        json = manifest.as_json
        assert_equal 1, json.length
        assert_equal 'Test', json[0]['name']
      end
    end

    context "when the doc doesn't have a meta file" do
      it "doesn't include the doc" do
        stub(store).exist?(meta_path) { false }
        assert_empty manifest.as_json
      end
    end
  end

  describe "#to_json" do
    it "returns the JSON string for #as_json" do
      stub(manifest).as_json { { test: 'ok' } }
      assert_equal "{\n  \"test\": \"ok\"\n}", manifest.to_json
    end
  end
end
