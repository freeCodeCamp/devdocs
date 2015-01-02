require 'fileutils'
require 'find'

module Docs
  class FileStore < AbstractStore
    private

    def read_file(path)
      File.read(path)
    end

    def create_file(path, value)
      FileUtils.mkpath File.dirname(path)

      if value.is_a? Tempfile
        FileUtils.move(value, path)
      else
        File.write(path, value)
      end
    end

    alias_method :update_file, :create_file

    def delete_file(path)
      if File.directory?(path)
        FileUtils.rmtree(path, secure: true)
      else
        FileUtils.rm(path)
      end
    end

    def file_exist?(path)
      File.exists?(path)
    end

    def file_mtime(path)
      File.mtime(path)
    end

    def file_size(path)
      File.size(path)
    end

    def list_files(path)
      Find.find path do |file|
        next if file == path
        Find.prune if File.basename(file)[0] == '.'
        yield file
        Find.prune unless File.exists?(file)
      end
    end
  end
end
