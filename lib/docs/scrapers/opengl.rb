module Docs
  class Opengl < FileScraper
    self.type = 'simple'
    self.root_path = 'index.php'
    self.links = {
      home: 'https://registry.khronos.org/OpenGL-Refpages/'
    }
    html_filters.push 'opengl/entries', 'opengl/clean_html'

    # indexflat.php is a copy of index.php
    options[:skip] = %w(indexflat.php)

    options[:attribution] = <<-HTML
    Copyright 2017-2021 The Khronos Group, Inc.. This work is licensed
    under a <a href="http://creativecommons.org/licenses/by/4.0/">Creative
    Commons Attribution 4.0 International License</a>.
    HTML

    version 'gl2.1' do
      self.root_path = 'index.html'
      self.release = 'gl2.1'
      self.base_url = "https://registry.khronos.org/OpenGL-Refpages/#{self.version}/"
    end
    version 'gl4' do
      self.root_path = 'index.php'
      self.release = 'gl4'
      self.base_url = "https://registry.khronos.org/OpenGL-Refpages/#{self.version}/"
    end

    def get_latest_version(opts)
      return 'v1.0.0'
    end
  end
end
