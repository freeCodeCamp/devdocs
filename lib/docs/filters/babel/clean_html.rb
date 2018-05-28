module Docs
  class Babel
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>Babel</h1>'
          return doc
        end

        header = at_css('.docs-header .col-md-12')
        @doc = at_css('.docs-content')
        doc.prepend_child(header)

        css('.btn-clipboard', '.package-links').remove

        css('.col-md-12', 'h1 a', 'h2 a', 'h3 a', 'h4 a', 'h5 a', 'h5 a').each do |node|
          node.before(node.children).remove
        end

        css('div.highlighter-rouge').each do |node|
          pre = node.at_css('pre')

          lang = node['class'][/language-(\w+)/, 1]
          lang = 'bash' if lang == 'sh'
          pre['data-language'] = lang

          pre.remove_attribute('class')
          pre.content = pre.content
          node.replace(pre)
        end

        css('code').remove_attr('class')

        doc
      end
    end
  end
end
