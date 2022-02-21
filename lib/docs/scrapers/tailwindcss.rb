module Docs
  class Tailwindcss < UrlScraper
    self.name = 'Tailwind CSS'
    self.type = 'tailwindcss'
    self.slug = 'tailwindcss'
    self.base_url = 'https://tailwindcss.com/docs'
    self.root_path = '/'
    self.release = '2.0.3'

    html_filters.push 'tailwindcss/entries', 'tailwindcss/clean_html'

    # options[:container] = 'body';

    # Fix redirects from older tailwind 2 docs
    options[:fix_urls] = lambda do |url|
      if url.include? "installation/"
        break "/docs/installation"
      end

      if url.end_with? "/breakpoints"
        break "/docs/screens#{/#.*$/.match(url)}"
      end
      if url.end_with? "/adding-base-styles"
        break "/docs/adding-custom-styles#adding-base-styles"
      end
      if url.end_with? "/ring-opacity"
        break "/docs/ring-color#changing-the-opacity"
      end

      if url.match(/\/colors#?/)
        break "/docs/customizing-colors#{/#.*$/.match(url)}"
      end
    end

    options[:skip_patterns] = [
      # Skip setup instructions
      /\/browser-support$/,
      /\/editor-setup$/,
      /\/installation$/,
      /\/optimizing-for-production$/,
      /\/upgrade-guide/,
      /\/using-with-preprocessors/
    ]

    #Obtainable from https://github.com/tailwindlabs/tailwindcss/blob/master/LICENSE
    options[:attribution] = <<-HTML
      &copy; Adam Wathan, Jonathan Reinink
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://tailwindcss.com/docs/installation', opts)
      doc.at_css('select option[value=v2]').inner_text[1..]
    end
  end
end
