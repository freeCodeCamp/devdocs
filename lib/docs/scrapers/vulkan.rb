module Docs
  # class Vulkan < FileScraper
  class Vulkan < UrlScraper
    self.name = 'Vulkan'

    self.slug = 'vk'
    self.type = 'vulkan'
    self.links = {
      home: 'https://www.khronos.org/registry/vulkan/specs/',
      code: 'https://github.com/KhronosGroup/Vulkan-Docs'
    }

    self.root_path = 'apispec.html'

    self.release = '1.0.56'
    # self.dir = '/mnt/d/theblackunknown/Documents/GitHub/Vulkan-Docs/out/1.0/'
    self.base_url = 'https://www.khronos.org/registry/vulkan/specs/1.0/'

    html_filters.push 'vulkan/entries', 'vulkan/clean_html'

    # in apispec.html, skip #header and #footer
    options[:container] = '#content'

    # If we only want API, we should skip this one
    options[:skip] = %w(
      html/vkspec.html
    )

    options[:attribution] = <<-HTML
      Copyright &copy; 2014-2017 Khronos Group. <br>
      This work is licensed under a Creative Commons Attribution 4.0 International License
    HTML
  end
end
