module Docs
  class Vulkan < UrlScraper
    self.name = 'Vulkan'
    self.type = 'simple'
    self.release = '1.0.59'
    self.base_url = 'https://www.khronos.org/registry/vulkan/specs/1.0/'
    self.root_path = 'apispec.html'
    self.links = {
      home: 'https://www.khronos.org/vulkan/'
    }

    html_filters.push 'vulkan/entries', 'vulkan/clean_html', 'title'

    options[:skip_links] = true
    options[:container] = '#content'
    options[:root_title] = 'Vulkan API Reference'

    options[:attribution] = <<-HTML
      &copy; 2014&ndash;2017 Khronos Group Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International License.<br>
      Vulkan and the Vulkan logo are registered trademarks of the Khronos Group Inc.
    HTML
  end
end
