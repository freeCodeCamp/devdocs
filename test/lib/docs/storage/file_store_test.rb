require_relative '../../../test_helper'
require_relative '../../../../lib/docs'

class DocsFileStoreTest < MiniTest::Spec
  let :store do
    Docs::FileStore.new(tmp_path)
  end

  after do
    FileUtils.rm_rf "#{tmp_path}/."
  end

  def expand_path(path)
    File.join(tmp_path, path)
  end

  def read(path)
    File.read expand_path(path)
  end

  def write(path, content)
    File.write expand_path(path), content
  end

  def exists?(path)
    File.exist? expand_path(path)
  end

  def touch(path)
    FileUtils.touch expand_path(path)
  end

  def mkpath(path)
    FileUtils.mkpath expand_path(path)
  end

  describe "#read" do
    it "reads a file" do
      write 'file', 'content'
      assert_equal 'content', store.read('file')
    end
  end

  describe "#write" do
    context "with a string" do
      it "creates the file when it doesn't exist" do
        store.write 'file', 'content'
        assert exists?('file')
        assert_equal 'content', read('file')
      end

      it "updates the file when it exists" do
        touch 'file'
        store.write 'file', 'content'
        assert_equal 'content', read('file')
      end
    end

    context "with a Tempfile" do
      let :file do
        Tempfile.new('tmp').tap do |file|
          file.write 'content'
          file.close
        end
      end

      it "creates the file when it doesn't exist" do
        store.write 'file', file
        assert exists?('file')
        assert_equal 'content', read('file')
      end

      it "updates the file when it exists" do
        touch 'file'
        store.write 'file', file
        assert_equal 'content', read('file')
      end
    end

    it "recursively creates directories" do
      store.write '1/2/file', ''
      assert exists?('1/2/file')
    end
  end

  describe "#delete" do
    it "deletes a file" do
      touch 'file'
      store.delete 'file'
      refute exists?('file')
    end

    it "deletes a directory" do
      mkpath '1/2'
      touch '1/2/file'
      store.delete '1'
      refute exists?('1/2/exist')
      refute exists?('1/2')
      refute exists?('1')
    end
  end

  describe "#exist?" do
    it "returns true when the file exists" do
      touch 'file'
      assert store.exist?('file')
    end

    it "returns false when the file doesn't exist" do
      refute store.exist?('file')
    end
  end

  describe "#mtime" do
    it "returns the file modification time" do
      touch 'file'
      created_at = Time.now.round - 86400
      modified_at = created_at + 1
      File.utime created_at, modified_at, expand_path('file')
      assert_equal modified_at, store.mtime('file')
    end
  end

  describe "#size" do
    it "returns the file's size" do
      write 'file', 'content'
      assert_equal File.size(expand_path('file')), store.size('file')
    end
  end

  describe "#each" do
    let :paths do
      paths = []
      store.each { |path| paths << path.remove(tmp_path) }
      paths
    end

    it "yields file paths" do
      touch 'file'
      assert_equal ['/file'], paths
    end

    it "yields directory paths" do
      mkpath 'dir'
      assert_equal ['/dir'], paths
    end

    it "yields file paths recursively" do
      mkpath 'dir'
      touch 'dir/file'
      assert_includes paths, '/dir/file'
    end

    it "yields directory paths recursively" do
      mkpath 'dir/dir'
      assert_includes paths, '/dir/dir'
    end

    it "doesn't yield file paths that start with '.'" do
      touch '.file'
      assert_empty paths
    end

    it "doesn't yield directory paths that start with '.'" do
      mkpath '.dir'
      assert_empty paths
    end

    it "yields directories before what's inside them" do
      mkpath 'dir'
      touch 'dir/file'
      assert paths.index('/dir') < paths.index('/dir/file')
    end

    context "when the block deletes the directory" do
      it "stops yielding what was inside it" do
        mkpath 'dir'
        touch 'dir/file'
        store.each do |path|
          (@paths ||= []) << path
          FileUtils.rm_rf(path) if path == expand_path('dir')
        end
        refute_includes @paths, expand_path('dir/file')
      end
    end
  end
end
