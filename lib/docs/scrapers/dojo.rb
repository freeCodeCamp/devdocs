module Docs
  class Dojo < UrlScraper
    include StubRootPage
    self.name = 'Dojo'
    self.slug = 'dojo'
    self.type = 'dojo'
    self.version = '1.10'
    self.base_url = 'http://dojotoolkit.org/api/1.10/'


    # Dojo expects all the requests to be xhrs or it redirects you back to the docs home page
    # where it uses js to call the backend based on the URL so you get the appropriate documentation
    self.headers = { 'User-Agent' => 'devdocs.io' , 'X-Requested-With' => 'XMLHttpRequest'  }
    self.links = {
      home: 'http://dojotoolkit.org',
      code: 'https://github.com/dojo/dojo'
    }

    html_filters.push 'dojo/clean_html', 'dojo/entries'

    # Don't use default selector on xhrs as no body or html document exists
    options[:container] = false

    def root_page_body
      require 'json'
      require 'set'
      response = Typhoeus::Request.new("dojotoolkit.org/api/1.10/tree.json",
          headers:  { 'User-Agent' => 'devdocs.io' , 'X-Requested-With' => 'XMLHttpRequest'  }).run
      treeJSON = JSON.parse(response.response_body)
      treeJSON = treeJSON["children"].bsearch { |framework| framework["name"] == "dojo" }
      @url_set = Set.new
      def get_url_list treeJSON
        @url_set.add(self.class.base_url + treeJSON["fullname"] + ".html?xhr=true")
        if (treeJSON["children"])
          treeJSON["children"].each do |child|
            get_url_list child
          end
        end
      end
      get_url_list treeJSON
      @url_set.map { |l| "<a href='#{l}'>#{l}</a>"}.join "<br>"
    end

    options[:attribution] = <<-HTML
      The Dojo Toolkit is Copyright &copy; 2005&ndash;2013 <br>
      Dual licensed under BSD 3-Clause and AFL.
    HTML
  end
end
