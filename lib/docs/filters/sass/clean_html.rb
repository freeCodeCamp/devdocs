module Docs
  class Sass
    class CleanHtmlFilter < Filter
      def call

        css('.sl-c-alert').remove

        css('.sl-l-medium-holy-grail__navigation').remove

        css('.sl-r-banner').remove

        css('.site-footer').remove

        # Add id to code blocks
        css('pre.signature').each do |node|

          id = node.content

          if id.match(/\(/)
            id = id.scan(/.+\(/)[0].chop
          end

          if id.include?('$pi')
            node.set_attribute('id', 'pi')
          elsif id.include?('$e')
            node.set_attribute('id', 'e')
          else
            node.set_attribute('id', id)
          end

        end

        # Remove duplicate ids
        css('.sl-c-callout--function').each do |node|
           node.remove_attribute('id')
        end

        # Hidden title links
        css('.visuallyhidden').remove

        ### Syntax Highlight ###
        css('.highlight.scss', '.highlight.sass').each do |node|
          node['data-language'] = 'scss'
        end

        css('.highlight.css').each do |node|
          node['data-language'] = 'css'
        end

        doc

      end
    end
  end
end
