require 'pathname'

module Docs
  class AbstractStore
    class InvalidPathError < StandardError; end
    class LockError < StandardError; end

    include Instrumentable

    def initialize(path)
      path = Pathname.new(path).cleanpath
      raise ArgumentError if path.relative?
      @root_path = @working_path = path.freeze
    end

    def root_path
      @root_path.to_s
    end

    def working_path
      @working_path.to_s
    end

    def expand_path(path)
      join_paths @working_path, path
    end

    def open(path, &block)
      if block_given?
        open_yield_close(path, &block)
      else
        set_working_path join_paths(@root_path, path)
      end
    end

    def close
      set_working_path @root_path
    end

    def read(path)
      path = expand_path(path)
      read_file(path) if file_exist?(path)
    end

    def write(path, value)
      path = expand_path(path)
      touch(path)

      if file_exist?(path)
        update(path, value)
      else
        create(path, value)
      end
    end

    def delete(path)
      path = expand_path(path)

      if file_exist?(path)
        destroy(path)
        true
      end
    end

    def exist?(path)
      file_exist? expand_path(path)
    end

    def mtime(path)
      path = expand_path(path)
      file_mtime(path) if file_exist?(path)
    end

    def size(path)
      path = expand_path(path)
      file_size(path) if file_exist?(path)
    end

    def each(&block)
      list_files(working_path, &block)
    end

    def replace(path = nil, &block)
      if path
        return open(path) { replace(&block) }
      else
        lock { track_touched { yield.tap { delete_untouched } } }
      end
    end

    private

    def read_file(path)
      raise NotImplementedError
    end

    def create_file(path, value)
      raise NotImplementedError
    end

    def update_file(path, value)
      raise NotImplementedError
    end

    def delete_file(path)
      raise NotImplementedError
    end

    def file_exist?(path)
      raise NotImplementedError
    end

    def file_mtime(path)
      raise NotImplementedError
    end

    def file_size(path)
      raise NotImplementedError
    end

    def list_files(path, &block)
      raise NotImplementedError
    end

    def set_working_path(path)
      @working_path = Pathname.new(path).freeze if assert_unlocked
    end

    def join_paths(base, path)
      base = Pathname.new(base).cleanpath
      path = Pathname.new(path).cleanpath
      path = base + path unless path.absolute?

      unless File.join(path, '').start_with? File.join(base, '')
        raise InvalidPathError, "Tried accessing #{path} outside #{base}"
      end

      path.to_s
    end

    def open_yield_close(path)
      working_path_was = working_path
      open(path)
      yield
    ensure
      set_working_path working_path_was
    end

    def create(path, value)
      instrument 'create.store', path: path do
        create_file(path, value)
      end
    end

    def update(path, value)
      instrument 'update.store', path: path do
        update_file(path, value)
      end
    end

    def destroy(path)
      instrument 'destroy.store', path: path do
        delete_file(path)
      end
    end

    def lock
      assert_unlocked
      @locked = true
      yield
    ensure
      @locked = false
    end

    def assert_unlocked
      raise LockError if @locked
      true
    end

    def track_touched
      @touched = []
      yield
    ensure
      @touched = nil
    end

    def touch(path)
      @touched << path if @touched
    end

    def touched?(path)
      dir = File.join(path, '')

      @touched.any? do |touched_path|
        touched_path == path || touched_path.start_with?(dir)
      end
    end

    def delete_untouched
      return if @touched.empty?

      each do |path|
        destroy(path) unless touched?(path)
      end
    end
  end
end
