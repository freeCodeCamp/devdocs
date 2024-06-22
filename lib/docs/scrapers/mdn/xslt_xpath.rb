module Docs
  class XsltXpath < Mdn
    # release = '2022-09-06'
    self.name = 'XSLT & XPath'
    self.slug = 'xslt_xpath'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web'
    self.root_path = '/XSLT'
    self.initial_paths = %w(/XPath)

    html_filters.push 'xslt_xpath/clean_html', 'xslt_xpath/entries'

    options[:root_title] = 'XSLT'

    options[:only_patterns] = [/\A\/XSLT/, /\A\/XPath/]

  end
end
