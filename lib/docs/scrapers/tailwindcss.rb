module Docs
  class Tailwindcss < UrlScraper
    self.name = 'Tailwind CSS'
    self.type = 'tailwindcss'
    self.slug = 'tailwindcss'
    self.base_url = 'https://tailwindcss.com/docs'
    self.root_path = '/installation'
    self.release = '8.5'

    html_filters.push 'tailwindcss/entries', 'tailwindcss/clean_html'

    # options[:container] = 'body';

    options[:skip_patterns] = [
        %r{\/guides\/.*},
        %r{\/colors\z}
      ]

    #Obtainable from https://github.com/tailwindlabs/tailwindcss/blob/master/LICENSE
    options[:attribution] = <<-HTML
      MIT License<br>
      Copyright (c) Adam Wathan <adam.wathan@gmail.com><br>
      Copyright (c) Jonathan Reinink <jonathan@reinink.ca><br>
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://tailwindcss.com/docs/installation', opts)
      doc.at_css('select option[value=v2]').inner_text
    end
  end
end
