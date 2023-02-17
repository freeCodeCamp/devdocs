module Docs
  class PointCloudLibrary < UrlScraper
    self.name = 'PointCloudLibrary'
    self.type = 'point_cloud_library'
    self.slug = 'point_cloud_library'
    self.base_url = 'https://pointclouds.org/documentation/'
    self.root_path = 'modules.html'
    # Add hierarchy.html to crawl all classes*.html that's not reachable from modules.html
    self.initial_paths = [
      "https://pointclouds.org/documentation/hierarchy.html"
    ]
    self.release = '1.13.0'

    self.links = {
      home: 'https://pointclouds.org/',
      code: 'https://github.com/PointCloudLibrary/pcl'
    }

    html_filters.push 'point_cloud_library/entries', 'point_cloud_library/clean_html'

    # Remove the `clean_text` because Doxygen are actually creating empty
    # anchor such as <a id="asd"></a> to do anchor link.. and that anchor
    # will be removed by clean_text
    self.text_filters = FilterStack.new
    text_filters.push 'images', 'inner_html', 'attribution'

    def get_latest_version(opts)
      get_latest_github_release('PointCloudLibrary', 'pcl', opts)[4..]
    end

    options[:attribution] = <<-HTML
      &copy; 2009–2012, Willow Garage, Inc.<br>
      &copy; 2012–, Open Perception, Inc.<br>
      Licensed under the BSD License.
    HTML

    # Skip source code since it doesn't provide any useful docs
    options[:skip_patterns] = [/_source/, /namespace/, /h\.html/, /structsvm/, /struct_/, /classopenni/, /class_/]

  end
end
