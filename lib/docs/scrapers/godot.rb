module Docs
  class Godot < UrlScraper
    self.type = 'sphinx_simple'
    self.links = {
      home: 'https://godotengine.org/',
      code: 'https://github.com/godotengine/godot'
    }

    html_filters.push 'godot/entries', 'godot/clean_html', 'sphinx/clean_html'

    # `learning/` contains the guided learning materials, and `classes/`
    # contains the API reference.
    options[:only_patterns] = [/\Alearning\//, /\Aclasses\//]

    options[:attribution] = <<-HTML
      &copy; Copyright 2014&ndash;2017, Juan Linietsky, Ariel Manzur and the Godot community (CC-BY 3.0).
    HTML

    version '2.1' do
      self.release = '2.1'
      self.base_url = "http://docs.godotengine.org/en/#{self.version}/"
    end

  end
end
