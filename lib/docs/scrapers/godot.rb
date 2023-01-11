module Docs
  class Godot < UrlScraper
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://godotengine.org/',
      code: 'https://github.com/godotengine/godot'
    }

    options[:container] = '.document .section'

    options[:download_images] = false
    options[:only_patterns] = [/\Agetting_started\//, /\Aclasses\//]

    options[:attribution] = ->(filter) do
      if filter.subpath.start_with?('classes')
         <<-HTML
          &copy; 2014&ndash;2022 Juan Linietsky, Ariel Manzur, Godot Engine contributors<br>
          Licensed under the MIT License.
        HTML
      else
        <<-HTML
          &copy; 2014&ndash;2022 Juan Linietsky, Ariel Manzur and the Godot community<br>
          Licensed under the Creative Commons Attribution Unported License v3.0.
        HTML
      end
    end

    version '3.5' do
      self.release = '3.5.1'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      options[:container] = '.document > [itemprop="articleBody"] > section[id]'
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '3.4' do
      self.release = '3.4.5'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      options[:container] = '.document > [itemprop="articleBody"] > section[id]'
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '3.3' do
      self.release = '3.3.0'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '3.2' do
      self.release = '3.2.3'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '2.1' do
      self.release = '2.1.6'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"

      options[:skip] = %w(classes/class_@global\ scope.html)
      options[:only_patterns] = [/\Alearning\//, /\Aclasses\//]

      html_filters.push 'godot/entries_v2', 'godot/clean_html_v2', 'sphinx/clean_html'
    end

    def get_latest_version(opts)
      get_latest_github_release('godotengine', 'godot', opts).split('-')[0]
    end
  end
end
