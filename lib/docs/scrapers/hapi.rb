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
      &copy; 2020 Sanctuary<br>
      &copy; 2016 Plaid Technologies, Inc.<br>
      Copyright &copy; 2011-2022, Project contributors Copyright &copy; 2011-2020, Sideway Inc Copyright &copy; 2011-2014, Walmart
      Copyright &copy; 2011, Yahoo Inc.
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

      Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      The names of any contributors may not be used to endorse or promote products derived from this software without specific prior written permission.
    HTML

    def get_latest_version(opts)
      get_npm_version("@hapi/hapi", opts)
    end

    private

  end

end
