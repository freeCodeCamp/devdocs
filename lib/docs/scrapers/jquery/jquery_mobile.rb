module Docs
  class JqueryMobile < Jquery
    self.name = 'jQuery Mobile'
    self.slug = 'jquerymobile'
    self.version = '1.4.0'
    self.base_url = 'http://local.api.jquerymobile.com'
    self.root_path = '/category/all'

    html_filters.insert_before 'jquery/clean_html', 'jquery_mobile/entries'

    options[:root_title] = 'jQuery Mobile'
    options[:skip] = %w(/tabs /theme)
    options[:skip_patterns].concat [/\A\/icons/]
    options[:replace_paths] = { '/select/' => '/selectmenu' }
  end
end
