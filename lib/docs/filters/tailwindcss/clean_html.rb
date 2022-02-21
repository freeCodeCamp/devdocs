# Removes all classes not allowlisted in the below semantic_classes array - such as tailwinds utility classes
def cleanup_tailwind_classes(node)
  class_name = node.attr("class")

  if class_name == nil
    return node.children.each { |child| cleanup_tailwind_classes(child) }
  end

  semantic_classes = ["code", "color-swatch", "color-swatch-container", "color-tone-information", "color-swatch-group", "color", "colors", "long-quick-reference"]

  classes = class_name.split.select do |klas|
    semantic_classes.include? klas
  end

  if classes.length === 0
    node.delete("class")
  else
    node.set_attribute("class", classes.join(" "))
  end

  node.children.each { |child| cleanup_tailwind_classes(child) }
end

module Docs
  class Tailwindcss
    class CleanHtmlFilter < Filter
      def call
        # Remove main page headers (top level sticky)
        css('#__next > .sticky').remove
        # And anything absolutely positioned (fancy floating navigation elements we don't care about)
        css('#__next .absolute').remove
        # Remove the left-navigation we scraped
        css('nav').remove

        # Remove the duplicate category name at the top of the page - redundant
        at_css('header#header > div:first-child > p:first-child').remove

        # Remove the right navigation sidebar
        at_css('header#header').parent.css('> div:has(h5:contains("On this page"))').remove

        # Remove footer + prev/next navigation
        at_css('footer').remove

        css('#nav ul li').each do |node|
          link = node.css("a").attr('href').to_s
          if link.include? "https://"
            node.remove()
          end
        end

        # Remove right sidebar
        css('#content-wrapper > div > div.hidden.xl\:text-sm.xl\:block.flex-none.w-64.pl-8.mr-8 > div > div').each do |node|
          node.remove
        end

        # Remove buttons to expand lists - those are already expanded and the button is useless
        css('div > button:contains("Show all classes")').each do |node|
          node.parent.remove
        end

        # Remove class examples - not part of devdocs styleguide? (similar to bootstrap)
        # Refer to https://github.com/freeCodeCamp/devdocs/pull/1534#pullrequestreview-649818936
        css('.not-prose').each do |node|
          if node.parent.children.length == 1
            node.parent.remove
          else
            node.remove
          end
        end

        # Properly format code examples
        css('code.language-html').each do |node|
          node.name = 'pre';
          node['data-language'] = 'html'
          node.parent.name = 'div';
        end

        css('code.language-diff').each do |node|
          node.name = 'pre';
          node['data-language'] = 'diff'
          node.parent.name = 'div';
        end

        css('code.language-js').each do |node|
          node.name = 'pre';
          node['data-language'] = 'js'
          node.parent.name = 'div';
        end

        @doc.traverse { |node| cleanup_tailwind_classes(node) }

        #remove weird <hr> (https://github.com/damms005/devdocs/commit/8c9fbd859b71a2525b94a35ea994393ce2b6fedb#commitcomment-50091018)
        css('hr').remove

        doc
      end
    end
  end
end
