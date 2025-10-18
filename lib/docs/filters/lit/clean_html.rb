module Docs
  class Lit
    class CleanHtmlFilter < Filter
      def call

        css('.offscreen, #inlineToc, a.anchor, [aria-hidden="true"], #prevAndNextLinks').remove

        css('[tabindex]').remove_attribute('tabindex')

        # Removing the side navigation.
        css('#docsNavWrapper, #rhsTocWrapper').remove

        # Removing this extra div.
        div = at_css('#articleWrapper')
        article = div.at_css('article')
        article.remove_attribute('id')
        div.replace(article)

        # Expanding and replacing the <template>, statically.
        # This code is a hacky incomplete implementation of
        # https://github.com/lit/lit.dev/blob/main/packages/lit-dev-content/src/components/litdev-aside.ts
        css('litdev-aside').each do |node|
          frag = Nokogiri::HTML::DocumentFragment.new(node.document)
          template = node.at_css('template')
          aside = template.children.first
          aside['class'] = 'litdev-aside'
          frag.add_child(aside)
          template.remove
          div = Nokogiri::XML::Node.new('div', @doc)
          div.add_child(node.children)
          aside.add_child(div)
          node.replace(aside)
        end

        # Removing the live playground examples.
        # https://github.com/lit/lit.dev/blob/main/packages/lit-dev-content/src/components/litdev-example.ts
        # Someday we can try enabling the live examples by adding appropriate code to assets/javascripts/views/pages/.
        css('litdev-example').each do |node|
          node.remove
        end

        # Cleaning up the preformatted example code.
        css('pre:has(code[class])').each do |node|
          lang = node.at_css('code')['class']
          lang.sub! /^language-/, ''
          node.content = node.css('.cm-line').map(&:content).join("\n")
          node['data-language'] = lang
        end

        # Cleaning up example import.
        css('div.import').each do |node|
          pre = Nokogiri::XML::Node.new('pre', @doc)
          pre.content = node.css('.cm-line').map(&:content).join("\n")
          pre['data-language'] = 'javascript'
          node.replace(pre)
        end

        # Moving the "kind" to inside the header.
        # Because it looks better this way.
        css('.kindTag').each do |kindtag|
          heading = kindtag.parent
          next unless heading['class'].include? 'heading'
          h = heading.at_css('h2, h3, h4')
          h.prepend_child(kindtag)
        end

        # View source
        css('h2 ~ a.viewSourceLink, h3 ~ a.viewSourceLink, h4 ~ a.viewSourceLink').each do |node|
          node['class'] = 'view-source'
          node.content = 'Source'
          node.previous_element << node
        end

        css('.mdnIcon').each do |node|
          parent = node.parent
          node.remove
          parent.content = parent.content.strip
        end

        doc
      end
    end
  end
end
