module Docs

  class Hapi < UrlScraper
    self.name = "Hapi"
    self.slug = "hapi"
    self.type = "hapi"
    self.release = "21.3.2"
    self.base_url = "https://hapi.dev/api/?v=#{self.release}"
    self.links = {
      home: "https://hapi.dev/",
      code: "https://github.com/hapijs/hapi",
    }

    html_filters.push "hapi/entries", "hapi/clean_html"

    options[:container] = '.markdown-wrapper'
    options[:title] = "Hapi"
    options[:attribution] = <<-HTML
      Copyright &copy; 2011-2022, Project contributors Copyright &copy; 2011-2020, Sideway Inc Copyright &copy; 2011-2014, Walmart<br>
      Copyright &copy; 2011, Yahoo Inc.<br>
      Licensed under the BSD 3-clause License.
    HTML

    def get_latest_version(opts)
      get_npm_version("@hapi/hapi", opts)
    end

    private

  end

end
