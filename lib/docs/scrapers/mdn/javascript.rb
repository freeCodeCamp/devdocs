module Docs
  class Javascript < Mdn
    prepend FixInternalUrlsBehavior
    prepend FixRedirectionsBehavior

    # release = '2023-04-24'
    self.name = 'JavaScript'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/javascript'
    }

    html_filters.push 'javascript/clean_html', 'javascript/entries'

    options[:root_title] = 'JavaScript'

    # Duplicates
    options[:skip] = %w(
      /Global_Objects
      /Operators
      /Statements)

    options[:skip_patterns] = [
      /additional_examples/i,
      /noSuchMethod/i,
      /Deprecated_and_obsolete_features/
    ]

    options[:replace_paths] = {
      '/template_strings' => '/Template_literals',
      '/Functions_and_function_scope/Strict_mode' => '/Strict_mode'
    }

    options[:fix_urls] = ->(url) do
      url.sub! 'https://developer.mozilla.org/en-US/docs/JavaScript/Reference',  Javascript.base_url
      url.sub! 'https://developer.mozilla.org/en/JavaScript/Reference',          Javascript.base_url
      url.sub! 'https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference', Javascript.base_url
      url.sub! 'https://developer.mozilla.org/En/Core_JavaScript_1.5_Reference', Javascript.base_url
      url.sub! '/Operators/Special/', '/Operators/'
      url.sub! 'Destructing_assignment', 'Destructuring_assignment'
      url.sub! '/Functions_and_function_scope', '/Functions'
      url.sub! 'Array.prototype.values()', 'values'
      url.sub! '%2A', '*'
      url.sub! '%40', '@'
      url
    end
  end
end
