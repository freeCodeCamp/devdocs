module Docs
  class JqueryMobile < Jquery
    self.name = 'jQuery Mobile'
    self.slug = 'jquerymobile'
    self.release = '1.4.5'
    self.base_url = 'https://api.jquerymobile.com'
    self.root_path = '/category/all'

    html_filters.insert_before 'jquery/clean_html', 'jquery_mobile/entries'

    options[:root_title] = 'jQuery Mobile'
    options[:skip] = %w(/tabs /theme)
    options[:skip_patterns] += [/\A\/icons/, /cdn-cgi/i]
    options[:replace_paths] = { '/select/' => '/selectmenu' }

    options[:fix_urls] = ->(url) do
      url.sub! 'http://api.jquerymobile.com/', 'https://api.jquerymobile.com/'
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://jquerymobile.com/', opts)
      doc.at_css('.download-box > .download-option:last-child > span').content.sub(/Version /, '')
    end
  end
end
