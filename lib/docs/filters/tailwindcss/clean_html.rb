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

        css('svg').remove if root_page?

        # Remove the duplicate category name at the top of the page - redundant
        at_css('header#header > div:first-child > p:first-child').remove

        # Remove the right navigation sidebar
        at_css('header#header').parent.css('> div:has(h5:contains("On this page"))').remove

        # Remove footer + prev/next navigation
        at_css('footer').remove

        # Handle long lists of class reference that otherwise span several scrolled pages
        if class_reference = at_css('#class-reference')
          reference_container = class_reference.parent
          classes_container = reference_container.children.reject{ |child| child == class_reference }.first

          rows = classes_container.css("tr")

          if rows.length > 10
            classes_container.set_attribute("class", "long-quick-reference")
          end
        end

        # Remove border color preview column as it isn't displayed anyway
        if result[:path] == "border-color" and class_reference = at_css('#class-reference')
          class_reference.parent.css("thead th:nth-child(3)").remove
          class_reference.parent.css("tbody td:nth-child(3)").remove
        end

        if result[:path] == "customizing-colors"
          # It's nice to be able to quickly find out what a color looks like
          css('div[style^="background-color:"]').each do |node|
            node.set_attribute("class", "color-swatch")

            swatch_container = node.parent
            swatch_container.set_attribute("class", "color-swatch-container")
            swatch_container.children.reject{ |child| child == node }.first.set_attribute("class", "color-tone-information")

            swatch_group = swatch_container.parent
            swatch_group.set_attribute("class", "color-swatch-group")

            color = swatch_group.parent
            color.set_attribute("class", "color")

            color_list = color.parent.parent
            color_list.set_attribute("class", "colors")
          end
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
        css('pre > code:first-child').each do |node|
          node.parent['data-language'] = node['class'][/language-(\w+)/, 1] if node['class'] and node['class'][/language-(\w+)/]
          node.parent.content = node.parent.content
        end

        @doc.traverse { |node| cleanup_tailwind_classes(node) }

        #remove weird <hr> (https://github.com/damms005/devdocs/commit/8c9fbd859b71a2525b94a35ea994393ce2b6fedb#commitcomment-50091018)
        css('hr').remove

        doc
      end

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
    end
  end
end
