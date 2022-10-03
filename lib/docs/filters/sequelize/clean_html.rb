module Docs
  class Sequelize
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article', '.content')

        if at_css('header > h1')
          # Pull the header out of its container
          header = at_css('h1')
          header.parent.add_previous_sibling header
        end

        # Remove header notice
        css('.header-notice').remove

        # Change td in thead to th
        css('table > thead > tr > td').each do |node|
          node.name = 'th'
        end

        # Add syntax highlighting to code blocks
        css('pre[class^="prism-code language-"]').each do |node|
          node['data-language'] = node['class'][/language-(\w+)/, 1] if node['class'] and node['class'][/language-(\w+)/]
          node.content = node.css('.token-line').map(&:content).join("\n")
        end

        # Return the cleaned-up document
        at_css('.markdown') || doc
      end
    end
  end
end
