module Docs
  class Javascript < Mdn
    prepend FixInternalUrlsBehavior
    prepend FixRedirectionsBehavior

    self.name = 'JavaScript'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'

    html_filters.push 'javascript/clean_html', 'javascript/entries', 'title'

    options[:mdn_tag] = 'JavaScript'

    options[:root_title] = 'JavaScript'

    # Don't want
    options[:skip] = %w(
      /Methods_Index
      /Properties_Index
      /Operators/Legacy_generator_function
      /Statements/Legacy_generator_function)

    # Duplicates
    options[:skip].concat %w(
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
