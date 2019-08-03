module Docs
  class Svg < Mdn
    prepend FixInternalUrlsBehavior
    prepend FixRedirectionsBehavior

    self.name = 'SVG'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/SVG'

    html_filters.push 'svg/clean_html', 'svg/entries', 'title'

    options[:mdn_tag] = 'XSLT_Reference'

    options[:root_title] = 'SVG'

    options[:title] = ->(filter) do
      if filter.slug.starts_with?('Element/')
        "<#{filter.default_title}>"
      elsif filter.slug != 'Attribute' && filter.slug != 'Element'
        filter.default_title
      else
        false
      end
    end

    options[:skip] = %w(/Compatibility_sources /FAQ)

    options[:fix_urls] = ->(url) do
      url.sub! 'https://developer.mozilla.org/en-US/Web/SVG', Svg.base_url
      url.sub! 'https://developer.mozilla.org/en-US/docs/SVG', Svg.base_url
      url.sub! 'https://developer.mozilla.org/en/SVG', Svg.base_url
      url
    end
  end
end
