module Docs
  class Godot < UrlScraper
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://godotengine.org/',
      code: 'https://github.com/godotengine/godot'
    }
    # godot docs since 3.5 don't link everything from the index.
    self.initial_paths = %w[
      getting_started/introduction/index.html
      getting_started/step_by_step/index.html
      classes/index.html
    ]

    options[:container] = '.document > [itemprop="articleBody"]'
    options[:download_images] = false
    options[:only_patterns] = [%r{\Agetting_started/}, %r{\Aclasses/}]

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;present Juan Linietsky, Ariel Manzur and the Godot community<br>
      Licensed under the Creative Commons Attribution Unported License v3.0.
    HTML

    version '4.2' do
      self.release = '4.2.2'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '3.5' do
      self.release = '3.5.3'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"

      # godot 3.5 upstream docs are formatted like godot4
      html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'
    end

    version '3.4' do
      self.release = '3.4.5'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"

      options[:container] = '.document > [itemprop="articleBody"] > section[id]'
      html_filters.push 'godot/entries_v3', 'godot/clean_html_v3', 'sphinx/clean_html'
    end

    version '3.3' do
      self.release = '3.3.0'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      self.initial_paths = %w[/index.html]

      options[:only_patterns] = [%r{\Aclasses/}]
      options[:container] = '.document .section'
      html_filters.push 'godot/entries_v3', 'godot/clean_html_v3', 'sphinx/clean_html'
    end

    version '3.2' do
      self.release = '3.2.3'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      self.initial_paths = %w[/index.html]

      options[:only_patterns] = [%r{\Aclasses/}]
      options[:container] = '.document .section'
      html_filters.push 'godot/entries_v3', 'godot/clean_html_v3', 'sphinx/clean_html'
    end

    version '2.1' do
      self.release = '2.1.6'
      self.base_url = "https://docs.godotengine.org/en/#{self.version}/"
      self.initial_paths = %w[/index.html]

      options[:skip] = %w(classes/class_@global\ scope.html)
      options[:only_patterns] = [%r{\Alearning/}, %r{\Aclasses/}]
      options[:container] = '.document .section'
      html_filters.push 'godot/entries_v2', 'godot/clean_html_v2', 'sphinx/clean_html'
    end

    def get_latest_version(opts)
      get_latest_github_release('godotengine', 'godot', opts).split('-')[0]
    end
  end
end
