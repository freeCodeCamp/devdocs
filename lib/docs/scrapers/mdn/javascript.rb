module Docs
  class Javascript < Mdn
    self.name = 'JavaScript'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'

    html_filters.push 'javascript/clean_html', 'javascript/entries', 'title'

    options[:root_title] = 'JavaScript'

    # Don't want
    options[:skip] = %w(
      /About
      /Code_comments
      /Deprecated_Features
      /Deprecated_and_obsolete_features
      /Functions_and_function_scope
      /Global_Objects/Iterator
      /Global_Objects/Proxy
      /Reserved_Words
      /Functions/arguments
      /arrow_functions
      /rest_parameters
      /default_parameters
      /Strict_mode
      /Functions/rest_parameters
      /Methods_Index
      /Properties_Index
      /Strict_mode/Transitioning_to_strict_mode
      /Operators/Legacy_generator_function
      /Statements/Legacy_generator_function)

    # Duplicates
    options[:skip].concat %w(
      /Global_Objects
      /Operators
      /Statements)

    options[:fix_urls] = ->(url) do
      url.sub! 'https://developer.mozilla.org/en-US/docs/JavaScript/Reference',  Javascript.base_url
      url.sub! 'https://developer.mozilla.org/en/JavaScript/Reference',          Javascript.base_url
      url.sub! 'https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference', Javascript.base_url
      url.sub! 'https://developer.mozilla.org/En/Core_JavaScript_1.5_Reference', Javascript.base_url
      url.sub! '/Operators/Special/', '/Operators/'
      url.sub! 'Destructing_assignment', 'Destructuring_assignment'
      url.sub! 'Array.prototype.values()', 'values'
      url
    end
  end
end
