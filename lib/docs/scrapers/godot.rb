module Docs
  class Godot < UrlScraper
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://godotengine.org/',
      code: 'https://github.com/godotengine/godot'
    }

    html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'

    options[:download_images] = false
    options[:container] = '.document .section'

    options[:only_patterns] = [/\Alearning\//, /\Aclasses\//]
    options[:skip] = %w(classes/class_@global\ scope.html)

    options[:attribution] = ->(filter) do
      if filter.subpath.start_with?('classes')
         <<-HTML
          &copy; 2014&ndash;2018 Juan Linietsky, Ariel Manzur, Godot Engine contributors<br>
          Licensed under the MIT License.
        HTML
      else
        <<-HTML
          &copy; 2014&ndash;2018 Juan Linietsky, Ariel Manzur and the Godot community<br>
          Licensed under the Creative Commons Attribution Unported License v3.0.
        HTML
      end
    end

    version '3.0' do
      self.release = '3.0'
      self.base_url = "http://docs.godotengine.org/en/#{self.version}/"
    end

    version '2.1' do
      self.release = '2.1'
      self.base_url = "http://docs.godotengine.org/en/#{self.version}/"
    end
  end
end
