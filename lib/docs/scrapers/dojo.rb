require 'yajl/json_gem'

module Docs
  class Dojo < UrlScraper
    self.type = 'dojo'
    self.release = '1.10'
    self.base_url = "http://dojotoolkit.org/api/#{release}/"

    # Dojo expects all the requests to be xhrs or it redirects you back to the docs home page
    # where it uses js to call the backend based on the URL so you get the appropriate documentation
    self.headers = { 'User-Agent' => 'devdocs.io' , 'X-Requested-With' => 'XMLHttpRequest'  }
    self.links = {
      home: 'http://dojotoolkit.org',
      code: 'https://github.com/dojo/dojo'
    }

    html_filters.push 'dojo/entries', 'dojo/clean_html', 'title'
    text_filters.push 'dojo/clean_urls'

    options[:container] = false
    options[:title] = false
    options[:root_title] = 'Dojo Toolkit'

    options[:only_patterns] = [/\Adojo\//]
    options[:skip_patterns] = [/dijit/, /dojox/]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2017 JS Foundation<br>
      Licensed under the AFL 2.1 and BSD 3-Clause licenses.
    HTML

    stub '' do
      response = request_one("#{self.base_url}tree.json")
      json = JSON.parse(response.body)
      urls = get_url_list(json)
      urls.map { |url| "<a href='#{url}'>#{url}</a>" }.join
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://dojotoolkit.org/api/', opts)
      doc.at_css('#versionSelector > option[selected]').content
    end

    private

    def get_url_list(json, set = Set.new)
      set.add("#{self.class.base_url}#{json['fullname']}.html?xhr=true")
      json['children'].each { |child| get_url_list(child, set) } if json['children']
      set
    end
  end
end
