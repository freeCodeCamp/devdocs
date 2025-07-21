module Docs
  class Astro
    class CleanHtmlFilter < Filter
      def call
        return '<h1>Astro</h1><p> Astro is a website build tool for the modern web — powerful developer experience meets lightweight output.</p>' if root_page?

        @doc = at_css('main')

        css('.anchor-link').remove
        css('.avatar-list').remove

        css('div > div > h1').each do |node|
          node.parent.parent.before(node).remove
        end

        css('pre').each do |node|
          node.content = node.css('.ec-line').map(&:content).join("\n")
          node.remove_attribute('style')
        end

        css('figcaption').each do |node|
          node.name = 'div'
          node['class'] = '_pre-heading'
        end

        css('figure').each do |node|
          node.before(node.children).remove
        end

        css('.cms-nav').remove

        css('.copy-button-wrapper, .copy-button-tooltip').remove

        css('footer ~ section', 'footer').remove

        doc
      end
    end
  end
end
