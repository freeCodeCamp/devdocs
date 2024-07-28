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
  end
end
