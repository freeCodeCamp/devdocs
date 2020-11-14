module Docs
  class XsltXpath < Mdn
    self.name = 'XSLT & XPath'
    self.slug = 'xslt_xpath'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web'
    self.root_path = '/XSLT'
    self.initial_paths = %w(/XPath)

    html_filters.push 'xslt_xpath/clean_html', 'xslt_xpath/entries', 'title'

    options[:mdn_tag] = 'XSLT_Reference'

    options[:root_title] = 'XSLT'

    options[:only_patterns] = [/\A\/XSLT/, /\A\/XPath/]

    options[:fix_urls] = ->(url) do
      url.sub! 'https://developer.mozilla.org/en-US/docs/Web/XSLT/Element', "#{XsltXpath.base_url}/XSLT"
      url
    end
  end
end
