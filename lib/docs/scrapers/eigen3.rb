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

    html_filters.push 'eigen3/entries', 'eigen3/clean_html', 'title'

    # Remove the `clean_text` because Doxygen are actually creating empty
    # anchor such as <a id="asd"></a> to do anchor link.. and that anchor
    # will be removed by clean_text
    self.text_filters = FilterStack.new
    text_filters.push 'images', 'inner_html', 'attribution'



    def get_latest_version(opts)
      tags = get_gitlab_tags("gitlab.com", "libeigen", "eigen", opts)
      tags[0]['name']
    end

    options[:attribution] = <<-HTML
      &copy; Eigen.<br>
      Licensed under the MPL2 License.
    HTML

    # Skip source code since it doesn't provide any useful docs
    options[:skip_patterns] = [/_source/, /-members/, /__Reference\.html/, /_chapter\.html/, /\.txt/, /\.tgz/]

    # TODO: replace cppreference
    # options[:replace_urls] = { 'http://en.cppreference.com/w/cpp/' => 'cpp/' }

    def parse(response) # Hook here because Nokogori removes whitespace from code fragments
      last_idx = 0
      # Process nested <div>s inside code fragment div.
      while not (last_idx = response.body.index('<div class="fragment">', last_idx)).nil?
        # enter code fragment <div>
        level = 1
        while not (last_idx = response.body.index(/<\/?div/, last_idx+1)).nil?
          # skip nested divs inside.
          if response.body[last_idx..last_idx+3] == '<div'
            level += 1
          else
            level -= 1
          end
          break if level == 0 # exit code fragment
        end
        if not last_idx.nil? and response.body[last_idx..last_idx+5] == '</div>'
          response.body[last_idx..last_idx+5] = '</pre>'
        end
      end
      response.body.gsub! /[\r\n\s]*<div class="ttc"[^>]*>.*<\/div>[\r\n\s]*/, ""
      response.body.gsub! /<div class="line">(.*?)<\/div>/m, "\\1"
      response.body.gsub! '<div class="fragment">', '<pre class="fragment" data-language="cpp">'
      super
    end

    def process_response?(response)
      return false unless super
      # Remove Empty pages.
      response.body.index(/<div class="contents">[\r\n\s]*<\/div>/m).nil? and \
        response.body.index(/<p>TODO: write this dox page!<\/p>/).nil?
    end
  end
end
