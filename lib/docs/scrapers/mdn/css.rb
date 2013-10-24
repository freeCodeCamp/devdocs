module Docs
  class Css < Mdn
    self.name = 'CSS'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/CSS'
    self.root_path = '/Reference'

    html_filters.push 'css/clean_html', 'css/entries', 'title'

    options[:root_title] = 'CSS'

    # Don't want
    options[:skip] = %w(
      /Syntax
      /At-rule
      /Comments
      /Specificity
      /actual_value
      /initial_value
      /inheritance
      /specified_value
      /computed_value
      /used_value actual_value
      /box_model
      /Replaced_element
      /Value_definition_syntax
      /Pseudo-elements
      /Layout_mode
      /Visual_formatting_model
      /Shorthand_properties
      /margin_collapsing
      /CSS3
      /Pseudo-classes
      /CSS_values_syntax
      /Media/Visual
      /block_formatting_context)

    options[:skip_patterns] = [/\-webkit/, /\-moz/, /Extensions/, /Tools/]

    # Broken / Empty
    options[:skip].concat %w(/image())

    options[:fix_urls] = ->(url) do
      url.sub! %r{https://developer\.mozilla\.org/en\-US/docs/CSS/([a-z@:])}, "#{Css.base_url}/\\1"
      url
    end
  end
end
