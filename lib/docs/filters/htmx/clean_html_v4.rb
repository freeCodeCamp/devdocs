module Docs
  class Htmx
    class CleanHtmlV4Filter < Filter
      def call
        # site chrome: breadcrumb, "on this page" sidebar and disclosure, "copy page" buttons
        css('nav', 'aside', 'details#page-nav-disclosure', 'header .actions').remove
        css('i[class*="icon-"]').remove

        # the title sits in <header class="page-header"><div class="title-row"><h1><span>
        css('header.page-header').each do |header|
          header.css('.title-row', 'h1 > span').each { |wrapper| wrapper.replace(wrapper.children) }
          header.replace(header.children)
        end

        # headings link to themselves
        css('h1', 'h2', 'h3', 'h4', 'h5', 'h6').each do |heading|
          heading.css('a[href^="#"]').each do |link|
            link.replace(link.children) if link['href'] == "##{heading['id']}"
          end
        end

        # Replace Shiki's highlighting markup - along with the copy button and
        # the window decoration it wraps the code in - with the plain source.
        # DevDocs highlights the code itself, based on data-language.
        css('pre').each do |node|
          code = node.at_css('code')
          node.content = code.content if code
          node.remove_attribute('style')
          node.remove_attribute('tabindex')
        end

        # Tailwind classes and Astro scope markers are useless without the site's stylesheet
        doc.traverse do |node|
          next unless node.element?
          node.remove_attribute('class')
          node.attribute_nodes.each do |attribute|
            node.remove_attribute(attribute.name) if attribute.name.start_with?('data-astro-cid')
          end
        end

        doc
      end
    end
  end
end
