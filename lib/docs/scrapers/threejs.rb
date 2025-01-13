module Docs
  class Threejs < FileScraper
    self.name = 'Three.js'
    self.type = 'simple'
    self.slug = 'threejs'
    self.links = {
      home: 'https://threejs.org/',
      code: 'https://github.com/mrdoob/three.js'
    }

    html_filters.push 'threejs/entries', 'threejs/clean_html'

    # The content is directly in the body
    options[:container] = 'body'

    options[:skip] = %w(
      prettify.js
      lesson.js
      lang.css
      lesson.css
      editor.html
      list.js
      page.js
    )

    options[:only_patterns] = [
      /\Aapi\/en\/.+\.html/,   # API documentation
      /\Amanual\/en\/.+\.html/ # Manual pages
    ]

    options[:skip_patterns] = [
      /examples/,
      /\A_/,
      /\Aresources\//,
      /\Ascenes\//
    ]

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;#{Time.current.year} Three.js Authors<br>
      Licensed under the MIT License.
    HTML

    version '171' do
      self.release = '171'
      self.base_url = "https://threejs.org/docs"
    end

    def get_latest_version(opts)
      get_latest_github_release('mrdoob', 'three.js', opts)
    end

    def initial_paths
      paths = []
      json_path = File.expand_path("/tmp/list.json")
      json_content = File.read(json_path)
      json_data = JSON.parse(json_content)

      # Process both API and manual sections
      process_documentation(json_data['en'], paths)
      paths
    end

    private

    def process_documentation(data, paths, prefix = '')
      data.each do |category, items|
        if items.is_a?(Hash)
          if items.values.first.is_a?(String)
            # This is a leaf node with actual pages
            items.each do |name, path|
              paths << "#{path}.html"
            end
          else
            # This is a category with subcategories
            items.each do |subcategory, subitems|
              process_documentation(items, paths, "#{prefix}#{category}/")
            end
          end
        end
      end
    end
  end
end 