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

    options[:skip_patterns] = [

        # removed because it focuses on how to use Tailwind with some other niche
        # technologies and to also align with DevDoc's Vision, which is" to:"
        # "indexing only the minimum useful to most developers" that use Tailwind
        %r{\/guides\/.*},

        # removed so it is easy to "get_type" (see tailwindcss/entries.rb line #15)
        %r{\/colors\z}

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
