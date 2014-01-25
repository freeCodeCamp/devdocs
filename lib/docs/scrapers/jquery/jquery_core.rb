module Docs
  class JqueryCore < Jquery
    self.name = 'jQuery'
    self.version = 'up to 2.1.0'
    self.base_url = 'http://local.api.jquery.com'

    html_filters.insert_before 'jquery/clean_html', 'jquery_core/entries'

    options[:root_title] = 'jQuery'

    # Duplicates
    options[:skip] = %w(/selectors/odd /selectors/even /selectors/event
      /selected /checked)

    options[:replace_paths] = {
      '/index/'             => '/index/index',
      '/h/deferred.reject/' => '/deferred.reject' }
  end
end
