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
        css('div.sticky.top-0').remove
        css('.sr-only').remove
        css('#sidebar').remove

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

        # Remove advert
        css('#__next > div.py-2.bg-gradient-to-r.from-indigo-600.to-light-blue-500.overflow-hidden').each do |node|
          node.remove
        end

        # Remove footer prev/next navigation
        css('#content-wrapper > div > div > div.flex.leading-6.font-medium').each do |node|
          node.remove
        end

        css('code.language-html').each do |node|
          node.name = 'pre';
          node['data-language'] = 'html'
          node.parent.name = 'div';
          node.parent['class'] = node.parent['class'].gsub(/bg-.*?\b/, ' ');
          node.parent.parent['class'] = node.parent.parent['class'].gsub(/bg-.*?\b/, ' ');
        end

        css('code.language-diff').each do |node|
          node.name = 'pre';
          node['data-language'] = 'diff'
          node.parent.name = 'div';
          node.parent['class'] = node.parent['class'].gsub(/bg-.*?\b/, ' ');
          node.parent.parent['class'] = node.parent.parent['class'].gsub(/bg-.*?\b/, ' ');
        end

        css('code.language-js').each do |node|
          node.name = 'pre';
          node['data-language'] = 'js'
          node.parent.name = 'div';
          node.parent['class'] = node.parent['class'].gsub(/bg-.*?\b/, ' ');
          node.parent.parent['class'] = node.parent.parent['class'].gsub(/bg-.*?\b/, ' ');
        end

        @doc.traverse { |node| cleanup_tailwind_classes(node) }

        #remove weird <hr> (https://github.com/damms005/devdocs/commit/8c9fbd859b71a2525b94a35ea994393ce2b6fedb#commitcomment-50091018)
        css('hr').remove

        doc
      end
    end
  end
end
