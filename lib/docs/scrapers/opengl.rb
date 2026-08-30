module Docs
  class Opengl < FileScraper
    self.type = 'simple'
    self.name = 'OpenGL'
    self.root_path = 'index.php'
    self.links = {
      home: 'https://registry.khronos.org/OpenGL-Refpages/'
    }
    html_filters.push 'opengl/entries', 'opengl/clean_html'

    # indexflat.php is a copy of index.php
    options[:skip] = %w(indexflat.php)

    options[:attribution] = ->(filter) {
      # copyright is the last section in these pages
      return filter.css('h2:contains("Copyright") ~ p').inner_text
    }

    version '4' do
      self.root_path = 'index.php'
      self.release = '4'
      self.base_url = "https://registry.khronos.org/OpenGL-Refpages/gl#{self.version}/"
    end

    version '2.1' do
      self.root_path = 'index.html'
      self.release = '2.1'
      self.base_url = "https://registry.khronos.org/OpenGL-Refpages/gl#{self.version}/"
    end

    def get_latest_version(opts)
      self.class.release
    end

    private

    # The reference pages sit in a differently named directory per version
    SUBDIRECTORIES = { '4' => 'gl4/html', '2.1' => 'gl2.1/xhtml' }

    def download_source
      download_and_extract('https://github.com/KhronosGroup/OpenGL-Refpages/archive/refs/heads/main.tar.gz',
                           "OpenGL-Refpages-main/#{SUBDIRECTORIES.fetch(self.class.version)}")
    end
  end
end
