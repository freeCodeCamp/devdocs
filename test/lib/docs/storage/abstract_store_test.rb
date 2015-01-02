require 'test_helper'
require 'docs'

class DocsAbstractStoreTest < MiniTest::Spec
  InvalidPathError = Docs::AbstractStore::InvalidPathError
  LockError = Docs::AbstractStore::LockError

  let :path do
    '/'
  end

  let :store do
    Docs::AbstractStore.new(@path || path).tap do |store|
      store.extend FakeInstrumentation
    end
  end

  describe ".new" do
    it "raises an error with a relative path" do
      assert_raises ArgumentError do
        Docs::AbstractStore.new 'path'
      end
    end

    it "sets #root_path" do
      @path = '/path'
      assert_equal @path, store.root_path
    end

    it "expands #root_path" do
      @path = '/path/..'
      assert_equal '/', store.root_path
    end

    it "sets #working_path" do
      assert_equal store.root_path, store.working_path
    end
  end

  describe "#root_path" do
    it "can't be overwritten" do
      @path = '/path'
      store.root_path << '/..'
      assert_equal '/path', store.root_path
    end
  end

  describe "#working_path" do
    it "can't be overwritten" do
      @path = '/path'
      store.working_path << '/..'
      assert_equal '/path', store.working_path
    end
  end

  describe "#open" do
    it "raises an error when the store is locked" do
      assert_raises LockError do
        store.send :lock, &-> { store.open 'dir' }
      end
    end

    context "with a relative path" do
      it "updates #working_path relative to #root_path" do
        2.times { store.open 'dir' }
        assert_equal File.join(path, 'dir'), store.working_path
      end

      it "expands the new #working_path" do
        store.open './dir/../'
        assert_equal path, store.working_path
      end

      it "raises an error when the new #working_path is outside of #root_path" do
        @path = '/dir'
        assert_raises InvalidPathError do
          store.open '../dir2'
        end
      end
    end

    context "with an absolute path" do
      it "updates #working_path" do
        store.open File.join(path, 'dir')
        assert_equal File.join(path, 'dir'), store.working_path
      end

      it "expands the new #working_path" do
        store.open File.join(path, 'dir/..')
        assert_equal path, store.working_path
      end

      it "raises an error when the new #working_path is outside of #root_path" do
        @path = '/dir'
        assert_raises InvalidPathError do
          store.open '/dir2'
        end
      end
    end

    context "with a block" do
      it "calls the block" do
        store.open('dir') { @called = true }
        assert @called
      end

      it "returns the block's return value" do
        assert_equal 1, store.open('dir') { 1 }
      end

      it "updates #working_path while calling the block" do
        store.open 'dir' do
          assert_equal File.join(path, 'dir'), store.working_path
        end
      end

      it "resets #working_path to its previous value afterward" do
        store.open('dir')
        store.open('dir2') {}
        assert_equal File.join(path, 'dir'), store.working_path
      end

      it "resets #working_path even when the block fails" do
        assert_raises RuntimeError do
          store.open('dir') { raise }
        end
        assert_equal path, store.working_path
      end
    end
  end

  describe "#close" do
    it "resets #working_path to #root_path" do
      2.times { store.open 'dir' }
      store.close
      assert_equal path, store.working_path
    end

    it "raises an error when the store is locked" do
      assert_raises LockError do
        store.send :lock, &-> { store.close }
      end
    end
  end

  describe "#expand_path" do
    context "when #working_path is '/'" do
      before do
        store.open '/'
      end

      it "returns '/path' with './path'" do
        assert_equal '/path', store.expand_path('./path')
      end

      it "returns '/path' with '/path'" do
        assert_equal '/path', store.expand_path('/path')
      end
    end

    context "when #working_path is '/dir'" do
      before do
        store.open '/dir'
      end

      it "returns '/dir/path' with './path'" do
        assert_equal '/dir/path', store.expand_path('./path')
      end

      it "returns '/dir/path' with 'path/../path'" do
        assert_equal '/dir/path', store.expand_path('path/../path')
      end

      it "returns '/dir/path' with '/dir/path'" do
        assert_equal '/dir/path', store.expand_path('/dir/path')
      end

      it "raises an error with '..'" do
        assert_raises InvalidPathError do
          store.expand_path '..'
        end
      end

      it "raises an error with '/'" do
        assert_raises InvalidPathError do
          store.expand_path '/'
        end
      end
    end
  end

  describe "#read" do
    it "raises an error with a path outside of #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.read '../file'
      end
    end

    it "returns nil when the file doesn't exist" do
      dont_allow(store).read_file
      stub(store).file_exist?('/file') { false }
      assert_nil store.read('file')
    end

    it "returns #read_file when the file exists" do
      stub(store).read_file('/file') { 1 }
      stub(store).file_exist?('/file') { true }
      assert_equal 1, store.read('file')
    end
  end

  describe "#write" do
    it "raises an error with a path outside of #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.write '../file', ''
      end
    end

    context "when the file doesn't exist" do
      before do
        stub(store).file_exist?('/file') { false }
        stub(store).create_file
      end

      it "returns #create_file" do
        stub(store).create_file('/file', '') { 1 }
        assert_equal 1, store.write('file', '')
      end

      it "instrument 'create'" do
        store.write 'file', ''
        assert store.last_instrumentation
        assert_equal 'create.store', store.last_instrumentation[:event]
        assert_equal '/file', store.last_instrumentation[:payload][:path]
      end
    end

    context "when the file exists" do
      before do
        stub(store).file_exist?('/file') { true }
        stub(store).update_file
      end

      it "returns #update_file" do
        stub(store).update_file('/file', '') { 1 }
        assert_equal 1, store.write('file', '')
      end

      it "instruments 'update'" do
        store.write 'file', ''
        assert store.last_instrumentation
        assert_equal 'update.store', store.last_instrumentation[:event]
        assert_equal '/file', store.last_instrumentation[:payload][:path]
      end
    end
  end

  describe "#delete" do
    it "raises an error with a path outside og #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.delete '../file'
      end
    end

    it "returns nil when the file doesn't exist" do
      dont_allow(store).delete_file
      stub(store).file_exist?('/file') { false }
      assert_nil store.delete('file')
    end

    context "when the file exists" do
      before do
        stub(store).file_exist?('/file') { true }
        stub(store).delete_file
      end

      it "calls #delete_file" do
        mock(store).delete_file('/file')
        store.delete 'file'
      end

      it "returns true" do
        assert store.delete('file')
      end

      it "instruments 'destroy'" do
        store.delete 'file'
        assert store.last_instrumentation
        assert_equal 'destroy.store', store.last_instrumentation[:event]
        assert_equal '/file', store.last_instrumentation[:payload][:path]
      end
    end
  end

  describe "exist?" do
    it "raises an error with a path outside of #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.exist? '../file'
      end
    end

    it "returns #file_exist?" do
      stub(store).file_exist?('/file') { 1 }
      assert_equal 1, store.exist?('file')
    end
  end

  describe "mtime" do
    it "raises an error with a path outside of #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.mtime '../file'
      end
    end

    it "returns nil when the file doesn't exist" do
      stub(store).file_exist?('/file') { false }
      dont_allow(store).file_mtime
      assert_nil store.mtime('file')
    end

    it "returns #file_mtime when the file exists" do
      stub(store).file_exist?('/file') { true }
      stub(store).file_mtime('/file') { 1 }
      assert_equal 1, store.mtime('file')
    end
  end

  describe "#size" do
    it "raises an error with a path outside of #working_path" do
      @path = '/path'
      assert_raises InvalidPathError do
        store.size '../file'
      end
    end

    it "returns nil when the file doesn't exist" do
      stub(store).file_exist?('/file') { false }
      dont_allow(store).file_size
      assert_nil store.size('file')
    end

    it "returns #file_size when the file exists" do
      stub(store).file_exist?('/file') { true }
      stub(store).file_size('/file') { 1 }
      assert_equal 1, store.size('file')
    end
  end

  describe "#each" do
    it "calls #list_files with #working_path" do
      store.open 'dir'
      block = Proc.new {}
      mock(store).list_files(File.join(path, 'dir'), &block)
      store.each(&block)
    end
  end

  describe "#replace" do
    before do
      stub(store).file_exist?
      stub(store).create_file
      stub(store).delete_file
    end

    def stub_paths(*paths)
      stub(store).each { |block| paths.each(&block) }
    end

    it "calls the block" do
      store.replace { @called = true }
      assert @called
    end

    it "returns the block's return value" do
      assert_equal 1, store.replace { 1 }
    end

    it "locks the store while calling the block" do
      assert_raises LockError do
        store.replace { store.open('dir') }
      end
      store.open 'dir'
    end

    context "with a path" do
      it "opens the path while calling the block" do
        store.replace 'dir' do
          assert_equal File.join(path, 'dir'), store.working_path
        end
      end
    end

    context "when the block writes no files" do
      it "doesn't delete files" do
        stub_paths '/', '/file'
        dont_allow(store).delete_file
        store.replace {}
      end
    end

    context "when the block writes files" do
      it "deletes untouched files" do
        stub_paths '/', '/dir', '/dir/file', '/dir/file2', '/dir2'
        mock(store).delete_file('/dir/file2').then.delete_file('/dir2')
        store.replace { store.write 'dir/file', '' }
      end

      it "doesn't delete touched files" do
        stub_paths '/', '/dir', '/dir/(file)'
        dont_allow(store).delete_file
        store.replace { store.write 'dir/(file)', '' }
      end
    end

    context "when the block fails" do
      it "doesn't delete files" do
        stub_paths '/', '/file'
        dont_allow(store).delete_file
        assert_raises RuntimeError do
          store.replace { store.write 'file2', ''; raise }
        end
      end

      it "unlocks the store afterward" do
        assert_raises RuntimeError do
          store.replace { raise }
        end
        store.open 'dir'
      end
    end

    context "when called multiple times" do
      before do
        stub_paths '/', '/file'
      end

      it "deletes untouched files that were touched the previous time" do
        store.replace { store.write 'file', '' }
        mock(store).delete_file '/file'
        store.replace { store.write 'file2', '' }
      end

      it "deletes untouched files that were touched and failed the previous time" do
        assert_raises RuntimeError do
          store.replace { store.write 'file', ''; raise }
        end
        mock(store).delete_file '/file'
        store.replace { store.write 'file2', '' }
      end
    end
  end
end
