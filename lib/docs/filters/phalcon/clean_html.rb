module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call

        # left navigation bar
        css('.doc-article-nav-wr').remove

        # right navigation bar
        css('.phalcon-blog__right-item').remove

        css('header').remove

        css('footer').remove

        # initial table of contents
        if !(slug=='index')
          css('.docSearch-content > ul').remove
        end

        css('hr').remove

        ### syntax highlight ###

        css('.highlighter-rouge').each do |node|

          next if node.classes.include?('language-yaml')
          next if node.classes.include?('language-ini')
          node.set_attribute('data-language', 'php')
          node.remove_class('highlighter-rouge')
          node.add_class('highlight-php')

          node.css('.kt').each do |subnode|
            subnode.remove_class('kt')
            subnode.add_class('token constant')
          end

          node.css('.nb, .n').each do |subnode|
            subnode.remove_class('nb')
            subnode.remove_class('n')
            subnode.add_class('token function')
          end

          node.css('.k, .kn, .kc, .cp').each do |subnode|
            subnode.remove_class('k')
            subnode.remove_class('kn')
            subnode.remove_class('kc')
            subnode.remove_class('cp')
            subnode.add_class('token keyword')
          end

          node.css('.nv, .no').each do |subnode|
            subnode.remove_class('nv')
            subnode.remove_class('no')
            subnode.add_class('token variable')
          end

          node.css('.s2').each do |subnode|
            subnode.remove_class('s2')
            subnode.add_class('token double-quoted-string string')
          end

          node.css('.p').each do |subnode|
            subnode.remove_class('p')
            subnode.add_class('token punctuation')
          end

          node.css('.nc, .nf').each do |subnode|
            subnode.remove_class('nc')
            subnode.remove_class('nf')
            subnode.add_class('token class-name')
          end

          node.css('.o').each do |subnode|
            subnode.remove_class('o')
            subnode.add_class('token operator')
          end

          node.css('.cd').each do |subnode|
            subnode.remove_class('cd')
            subnode.add_class('token comment')
          end

        end

        doc

      end
    end
  end
end
