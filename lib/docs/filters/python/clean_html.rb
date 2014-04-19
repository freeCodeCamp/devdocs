module Docs
  class Python
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css '.body > .section'

        # Clean inline code elements

        css('tt.literal').each do |node|
          node.before(node.children).remove
        end

        css('tt', 'span.pre').each do |node|
          node.name = 'code'
          node.remove_attribute 'class'
        end

        root_page? ? root : other

        doc
      end

      def root
        at_css('h1').content = 'Python'
        css('> p').remove
      end

      def other
        css('.headerlink', 'hr').remove

        # Clean headings

        at_css('h1').tap do |node|
          node.content = node.content.sub!(/\A[\d\.]+/) { |str| @levelRegexp = /\A#{str}/; '' }
        end

        css('h2', 'h3', 'h4').each do |node|
          node.css('a').each do |link|
            link.before(link.children).remove
          end
          node.child.content = node.child.content.remove @levelRegexp
        end

        css('dt').each do |node|
          node.content = node.content
        end

        # Remove blockquotes
        css('blockquote').each do |node|
          node.before(node.children).remove
        end

        # Remove code highlighting
        css('.highlight-python3').each do |node|
          pre = node.at_css('pre')
          pre.content = pre.content
          pre['class'] = 'python'
          node.replace(pre)
        end

        # Remove <table> border attribute
        css('table[border]').each do |node|
          node.remove_attribute 'border'
        end
      end
    end
  end
end
