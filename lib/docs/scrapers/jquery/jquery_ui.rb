module Docs
  class JqueryUi < Jquery
    self.name = 'jQuery UI'
    self.slug = 'jqueryui'
    self.version = '1.10.4'
    self.base_url = 'http://local.api.jqueryui.com'
    self.root_path = '/category/all'

    html_filters.insert_before 'jquery/clean_html', 'jquery_ui/entries'

    options[:root_title] = 'jQuery UI'
    options[:skip] = %w(/theming)
    options[:skip_patterns].concat [/\A\/1\./]
  end
end
