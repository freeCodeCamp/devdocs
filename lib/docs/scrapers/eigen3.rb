module Docs
  class Eigen3 < UrlScraper
    self.name = 'Eigen3'
    self.type = 'eigen3'
    self.slug = 'eigen3'
    self.base_url = 'https://eigen.tuxfamily.org/dox/'
    self.root_path = 'index.html'
    self.initial_paths = [
      "modules.html"
    ]
    self.release = '3.4.0'

    self.links = {
      home: 'https://eigen.tuxfamily.org',
      code: 'https://gitlab.com/libeigen/eigen'
    }

    html_filters.push 'eigen3/entries', 'eigen3/clean_html'

    # Remove the `clean_text` because Doxygen are actually creating empty
    # anchor such as <a id="asd"></a> to do anchor link.. and that anchor
    # will be removed by clean_text
    self.text_filters = FilterStack.new
    text_filters.push 'images', 'inner_html', 'attribution'



    def get_latest_version(opts)
      tags = get_gitlab_tags("https://gitlab.com", "libeigen", "eigen", opts)
      tags[0]['name']
    end

    options[:attribution] = <<-HTML
      &copy; Eigen.<br>
      Licensed under the MPL2 License.
    HTML

    # Skip source code since it doesn't provide any useful docs
    options[:skip_patterns] = [/_source/, /-members/, /__Reference\.html/, /_chapter\.html/,]

    # TODO: replace cppreference
    # options[:replace_urls] = { 'http://en.cppreference.com/w/cpp/' => 'cpp/' }

  end
end
