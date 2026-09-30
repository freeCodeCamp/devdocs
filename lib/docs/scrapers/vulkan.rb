module Docs
  class Vulkan < UrlScraper
    self.name = 'Vulkan'
    self.type = 'simple'
    self.release = '1.3.289'
    self.base_url = 'https://registry.khronos.org/vulkan/specs/1.3/html/'
    self.root_path = 'vkspec.html'
    self.links = {
      home: 'https://registry.khronos.org/vulkan'
    }

    html_filters.push 'vulkan/entries', 'vulkan/clean_html', 'title'

    options[:skip_links] = true
    options[:container] = '#content'
    options[:root_title] = 'Vulkan API Reference'

    options[:attribution] = <<-HTML
      &copy; 2024 Khronos Group Inc.<br>
      Licensed under the Creative Commons Attribution 4.0 International License.<br>
      Vulkan and the Vulkan logo are registered trademarks of the Khronos Group Inc.
    HTML

    def get_latest_version(opts)
      tags = get_github_tags('KhronosGroup', 'Vulkan-Docs', opts)
      tags[0]['name'][1..-1]
    end
  end
end
