module Docs
  class DomEvents < Mdn
    prepend FixInternalUrlsBehavior

    self.name = 'DOM Events'
    self.slug = 'dom_events'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/Events'

    html_filters.insert_after 'clean_html', 'dom_events/clean_html'
    html_filters.push 'dom_events/entries', 'title'

    options[:root_title] = 'DOM Events'

    options[:skip] = %w(/MozOrientation)
    options[:skip_patterns] = [/\A\/moz/i]

    options[:fix_urls] = ->(url) do
      url.sub! 'https://developer.mozilla.org/en-US/Mozilla_event_reference',      DomEvents.base_url
      url.sub! 'https://developer.mozilla.org/en-US/docs/Mozilla_event_reference', DomEvents.base_url
      url.sub! 'https://developer.mozilla.org/en-US/docs/Web/Reference/Events',    DomEvents.base_url
      url
    end
  end
end
