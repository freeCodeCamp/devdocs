module Docs

  class Joi < UrlScraper
    self.name = "Joi"
    self.slug = "joi"
    self.type = "joi"
    self.release = "17.9.1"
    self.base_url = "https://joi.dev/api/?v=#{self.release}"
    self.links = {
      home: "https://joi.dev/",
      code: "https://github.com/hapijs/joi",
    }

    html_filters.push "joi/entries", "joi/clean_html"

    options[:container] = '.markdown-wrapper'
    options[:title] = "Joi"
    options[:attribution] = <<-HTML
      Copyright &copy; 2012-2022, Project contributors Copyright &copy; 2012-2022, Sideway Inc Copyright &copy; 2012-2014, Walmart
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      The names of any contributors may not be used to endorse or promote products derived from this software without specific prior written permission.
    HTML

    def get_latest_version(opts)
      get_npm_version("joi", opts)
    end

    private

  end

end
