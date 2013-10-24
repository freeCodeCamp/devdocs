module Docs
  class Sass < UrlScraper
    self.type = 'yard'
    self.version = '3.2.12'
    self.base_url = 'http://sass-lang.com/docs/yardoc/'
    self.root_path = 'file.SASS_REFERENCE.html'

    html_filters.push 'sass/clean_html', 'sass/entries', 'title'

    options[:only] = %w(Sass/Script/Functions.html)

    options[:container] = ->(filter) do
      filter.root_page? ? '#filecontents' : '#instance_method_details'
    end

    options[:title] = ->(filter) do
      'Sass Functions' if filter.slug == 'Sass/Script/Functions'
    end

    options[:attribution] = <<-HTML.strip_heredoc
      &copy; 2006&ndash;2013 Hampton Catlin, Nathan Weizenbaum, and Chris Eppstein<br>
      Licensed under the MIT License.
    HTML
  end
end
