module Docs
  class Sinon < UrlScraper
    self.name = 'Sinon.JS'
    self.slug = 'sinon'
    self.type = 'sinon'
    self.links = {
      home: 'https://sinonjs.org/',
      code: 'https://github.com/sinonjs/sinon'
    }

    html_filters.push 'sinon/clean_html', 'sinon/entries'

    options[:title] = 'Sinon.JS'
    options[:container] = '.content .container'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2022 Christian Johansen<br>
      Licensed under the BSD License.
    HTML

    # Links in page point to '../page' what makes devdocs points to non-existent links
    options[:fix_urls] = -> (url) do
      if !(url =~ /releases\/v\d*/)
        url.gsub!(/.*releases\//, "")
      end

      url
    end

    RELEASE_MAPPINGS = {
      '15' => '15.0.1',
      '14' => '14.0.2',
      '13' => '13.0.1',
      '12' => '12.0.1',
      '11' => '11.1.2',
      '10' => '10.0.1',
      '9'  => '9.2.2.',
      '8'  => '8.1.1',
      '7'  => '7.5.0',
      '6'  => '6.3.5',
      '5'  => '5.1.0',
      '4'  => '4.5.0',
      '3'  => '3.3.0',
      '2'  => '2.4.1',
      '1'  => '1.17.7'
    }

    RELEASE_MAPPINGS.each do |ver, release|
      version ver do
        self.release = release
        self.base_url = "https://sinonjs.org/releases/v#{ver}/"
      end
    end

    def get_latest_version(opts)
      tags = get_github_tags('sinonjs', 'sinon', opts)
      tags[0]['name'][1..-1]
    end

  end
end
