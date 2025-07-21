module Docs
  class Tailwindcss
    class CleanHtmlFilter < Filter
      def call
        # Move h1 out of wrapper.
        css('h1').each do |node|
          doc.prepend_child(node)
        end

        # Remove main page headers (top level sticky)
        css('#__next > .sticky', 'div.fixed.inset-x-0.top-0').remove
        # And anything absolutely positioned (fancy floating navigation elements we don't care about)
        css('#__next .absolute', '.fixed').remove
        # Remove the left-navigation we scraped
        css('nav').remove

        css('svg').remove if root_page?

        # Remove the right navigation sidebar
        css('header#header', 'p[data-section]').each do |node|
          node.parent.css('> div:has(h5:contains("On this page"))').remove # v3

          node.parent.parent.css('div.max-xl\\:hidden').remove # v4
        end

        # Remove the duplicate category name at the top of the page - redundant
        css(
          'header#header > div:first-child > p:first-child', # v3
          'p[data-section]' # v4
        ).remove

        # Remove footer + prev/next navigation
        css('footer', '.row-start-5').remove

        # Handle long lists of class reference that otherwise span several scrolled pages
        if class_reference = at_css('#class-reference', '#quick-reference')
          reference_container = class_reference.parent
          classes_container = reference_container.children.reject{ |child| child == class_reference }.first

          rows = classes_container.css("tr")

          if rows.length > 10
            classes_container.set_attribute("class", "long-quick-reference")
          end
        end

        # Remove border color preview column as it isn't displayed anyway
        if result[:path] == "border-color" and class_reference = at_css('#class-reference', '#quick-reference')
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
        css(
          'div > button:contains("Show all classes")',
          'div > button:contains("Show more")'
        ).each do |node|
          node.parent.remove
        end

        # Remove class examples - not part of devdocs styleguide? (similar to bootstrap)
        # Refer to https://github.com/freeCodeCamp/devdocs/pull/1534#pullrequestreview-649818936
        css('.mt-4.-mb-3', 'figure', 'svg', '.flex.space-x-2').remove

        # Properly format code examples.
        css('pre > code:first-child').each do |node|
          # v4 doesn't provide language context, so it must be inferred imperfectly.
          node.parent['data-language'] =
            if node.content.include?('function')
              'jsx'
            elsif node.content.include?("</")
              'html'
            else
              'css'
            end

          node.parent.content =
            if version == '3'
              node.parent.content
            else
              node.css('.line').map(&:content).join("\n")
            end
        end

        # Remove headers some code examples have.
        css('.flex.text-slate-400.text-xs.leading-6', '.px-3.pt-0\\.5.pb-1\\.5').remove

        # Strip anchor from headers
        css('h2', 'h3').each do |node|
          node.content = node.inner_text
        end

        @doc.traverse { |node| cleanup_tailwind_classes(node) }

        # Remove weird <hr> (https://github.com/damms005/devdocs/commit/8c9fbd859b71a2525b94a35ea994393ce2b6fedb#commitcomment-50091018)
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
