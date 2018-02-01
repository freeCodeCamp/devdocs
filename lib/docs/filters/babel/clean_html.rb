module Docs
  class Babel
    class CleanHtmlFilter < Filter
      def call
        css('.btn-clipboard').remove

        css('div.highlighter-rouge').each do |node|
          pre = node.at_css('pre')

          # copy over the highlighting metadata
          match = /language-(\w+)/.match(node['class'])
          if match
            lang = match[1]
            if lang == 'sh'
              lang = 'bash'
            end
            pre['class'] = nil
            pre['data-language'] = lang
          end

          # Remove the server-rendered syntax highlighting
          code = pre.at_css('code')
          code.content = code.text

          # Remove the div.highlighter-rouge and div.highlight wrapping the <pre>
          node.add_next_sibling pre
          node.remove
        end


        css('blockquote').each do |node|
          node.name = 'div'
          node['class'] = '_note'
        end

        css((1..6).map { |n| "h#{n}" }).each do |header|
          return unless header.at_css('a')
          header.content = header.at_css('a').content
        end


        header = doc # .docs-content
          .parent # .row
          .parent # .container
          .previous_element # .docs_header

        toc = doc # .docs-content
          .parent # .row
          .at_css('.sidebar')
        toc['class'] = '_toc'
        toc.css('a').each do |a|
          a['class'] = '_toc-link'
          a.parent.remove if a.content == 'Community Discussion'
        end
        toc.css('ul').attr 'class', '_toc-list'

        h1 = header.at_css('h1')
        h1.content = h1.content
          .titleize
          .sub(/\bEnv\b/, 'env')
          .sub(/\.[A-Z]/) { |s| s.downcase }
          .sub(/\.babelrc/i, '.babelrc')
          .sub('Common Js', 'CommonJS')
          .sub('J Script', 'JScript')
          .sub(/regexp/i, 'RegExp')
          .sub(/api|Es(\d+)|cli|jsx?|[au]md/i) { |s| s.upcase }

        doc.children.before toc
        doc.children.before header.at_css 'p'
        doc.children.before h1

        doc
      end
    end
  end
end
