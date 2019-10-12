module Docs
  class Sequelize
    class CleanHtmlFilter < Filter
      def call
        # Clean up the home page
        if root_page?
          # Remove logo
          css('.manual-user-index > div > div.logo').remove
          # Convert title to proper H1 element
          at_css('.manual-user-index > div > div.sequelize').name = 'h1'
          # Remove badges (NPM, Travis, test coverage, etc.)
          css('.manual-user-index > p:nth-child(4)').remove
          # Remove image cards pointing to entries of the manual
          css('.manual-cards').remove
        end

        # Add syntax highlighting to code blocks
        css('pre > code[class^="lang-"]').each do |node|
          pre = node.parent
          # Convert the existing language definitions to Prism-compatible attributes
          pre['data-language'] = 'javascript' if node['class'] == 'lang-js' || node['class'] == 'lang-javascript'
          pre['data-language'] = 'json'       if node['class'] == 'lang-json'
          pre['data-language'] = 'shell'      if node['class'] == 'lang-sh' || node['class'] == 'lang-bash'
          pre['data-language'] = 'sql'        if node['class'] == 'lang-sql'
          pre['data-language'] = 'typescript' if node['class'] == 'lang-ts'
        end

        # Add syntax highlighting to source files
        css('pre.raw-source-code').each do |node|
          node['data-language'] = 'javascript'
        end

        # Return the cleaned-up document
        doc
      end
    end
  end
end
