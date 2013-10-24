module Docs
  module AutoloadHelper
    def autoload_all(path, suffix = '')
      Dir["#{Docs.root_path}/#{path}/**/*.rb"].each do |file|
        name = File.basename(file, '.rb') + (suffix ? "_#{suffix}" : '')
        autoload name.camelize, file
      end
    end
  end
end
