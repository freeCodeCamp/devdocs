module Docs
  class Celery
    class CleanHtmlFilter < Filter
      def call
        # 'This document describes the current stable version of Celery...'
        css('div.deck').remove
  
        css('.reference.external.image-reference').remove
        
        # Table of Contents.
        css('nav.contents.local', 'table.docutils').remove
        
        # ¶ anchor links, [source] external links.
        css('a.headerlink', 'a.toc-backref', '.viewcode-link', 'hr').remove

        css('h1', 'h2', 'h3', 'h4', 'h5', 'h6').each do |node|
          node.content = node.inner_text
        end

        css('.highlight-python pre', '.highlight-default pre', '.highlight-pycon pre').each do |node|
          node.content = node.content
          node['data-language'] = 'python'
          node.parent.parent.replace(node)
        end

        # Lists are wrapped in blockquotes for some reason.
        css('blockquote ol', 'blockquote ul').each do |node|
          node.parent.parent.replace(node)
        end

        doc
      end
    end
  end
end
