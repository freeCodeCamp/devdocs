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
      /Functions_and_function_scope/Strict_mode
      /Global_Objects/Iterator
      /Global_Objects/Number/toInteger
      /Global_Objects/ParallelArray
      /Global_Objects/Proxy
      /Global_Objects/uneval
      /Reserved_Words
      /arrow_functions
      /rest_parameters)

    options[:skip_patterns] = [/Intl/, /Collator/, /DateTimeFormat/, /NumberFormat/]

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
      url
    end
  end
end
