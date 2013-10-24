module Docs
  class Html < Mdn
    self.name = 'HTML'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/HTML/Element'

    html_filters.push 'html/clean_html', 'html/entries', 'title'

    options[:root_title] = 'HTML'

    options[:title] = ->(filter) do
      if filter.slug == 'Heading_Elements'
        'Heading Elements'
      else
        "<#{filter.default_title}>"
      end
    end

    options[:replace_paths] = {
      '/h1' => '/Heading_Elements',
      '/h2' => '/Heading_Elements',
      '/h3' => '/Heading_Elements',
      '/h4' => '/Heading_Elements',
      '/h5' => '/Heading_Elements',
      '/h6' => '/Heading_Elements' }
  end
end
