module Docs
  class NullStore < AbstractStore
    def initialize
      super '/'
    end

    private

    def nil(*args)
      nil
    end

    alias_method :read_file, :nil
    alias_method :create_file, :nil
    alias_method :update_file, :nil
    alias_method :delete_file, :nil
    alias_method :file_exist?, :nil
    alias_method :file_mtime, :nil
    alias_method :file_size, :nil
    alias_method :list_files, :nil
  end
end
