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
        css('.kt').each do |node|
          node.remove_attribute('class')
          node.add_class('token constant')
        end

        css('.k, .kn, .kc, .cp, .ow').each do |node|
          node.remove_attribute('class')
          node.add_class('token keyword')
        end

        css('.nv, .no').each do |node|
          node.remove_attribute('class')
          node.add_class('token variable')
        end

        css('.nb, .n').each do |node|
          node.remove_attribute('class')
          node.add_class('token string')
        end

        css('.p').each do |node|
          node.remove_attribute('class')
          node.add_class('token punctuation')
        end

        css('.nf').each do |node|
          node.remove_attribute('class')
          node.add_class('token function')
        end

        css('.o').each do |node|
          node.remove_attribute('class')
          node.add_class('token operator')
        end

        css('.c1, .cm, .c').each do |node|
          node.remove_attribute('class')
          node.add_class('token comment')
        end

        css('.mh, .m, .mi').each do |node|
          node.remove_attribute('class')
          node.add_class('token number')
        end

        css('.nc, .nt').each do |node|
          node.remove_attribute('class')
          node.add_class('token selector')
        end

        css('.nl').each do |node|
          node.remove_attribute('class')
          node.add_class('token property')
        end

        doc
      end
    end
  end
end
