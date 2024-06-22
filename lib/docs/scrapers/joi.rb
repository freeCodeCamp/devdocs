module Docs

  class Joi < UrlScraper
    self.name = "Joi"
    self.slug = "joi"
    self.type = "joi"
    self.release = "17.11.0"
    self.base_url = "https://joi.dev/api/?v=#{self.release}"
    self.links = {
      home: "https://joi.dev/",
      code: "https://github.com/hapijs/joi",
    }

    html_filters.push "joi/entries", "joi/clean_html"

    options[:container] = '.markdown-wrapper'
    options[:title] = "Joi"
    options[:attribution] = <<-HTML
      Copyright &copy; 2012-2022, Project contributors Copyright &copy; 2012-2022, Sideway Inc Copyright &copy; 2012-2014, Walmart<br>
      Licensed under the BSD 3-clause License.
    HTML

    def get_latest_version(opts)
      get_npm_version("joi", opts)
    end

    private

  end

end
