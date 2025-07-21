module Docs
  class Tailwindcss < UrlScraper
    self.name = 'Tailwind CSS'
    self.type = 'tailwindcss'
    self.slug = 'tailwindcss'
    self.root_path = '/'
    self.links = {
      home: 'https://tailwindcss.com/',
      code: 'https://github.com/tailwindlabs/tailwindcss'
    }

    html_filters.push 'tailwindcss/entries', 'tailwindcss/clean_html'

    # Disable the clean text filter which removes empty nodes - we'll do it ourselves more selectively
    text_filters.replace("clean_text", "tailwindcss/noop")

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
      &copy; Tailwind Labs Inc.
    HTML

    version do
      self.release = '4.1.11'
      self.base_url = 'https://tailwindcss.com/docs'

      # Fix redirects
      options[:fix_urls] = lambda do |url|
        if url.include? "installation/"
          break "/docs/installation"
        end

        if url.end_with? "text-color"
          break "/docs/color"
        end
      end
    end

    version '3' do
      self.release = '3.4.17'
      self.base_url = 'https://v3.tailwindcss.com/docs'

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
    end

    def get_latest_version(opts)
      get_latest_github_release('tailwindlabs', 'tailwindcss', opts)
    end
  end
end
