module Docs
  class Godot
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          at_css('h1').content = 'Godot Engine'
          at_css('.admonition.note').remove
        end
        css('.admonition-grid').remove

        css('p[id]').each do |node|
          heading = Nokogiri::XML::Node.new 'h3', doc.document
          heading['id'] = node['id']
          heading.children = node.children
          node.before(heading).remove
        end

        css('h3 strong').each do |node|
          node.before(node.children).remove
        end

        css('a.reference').remove_attr('class')

        # flatten gdscript+C# example blocks and add language name.
        css('div[role="tabpanel"]').each do |node|
          language_label = Nokogiri::XML::Node.new 'strong', doc.document
          language_name = 'GDScript' if node.at_css('div.highlight-gdscript')
          language_name = 'C#' if node.at_css('div.highlight-csharp')
          language_label.content = language_name.to_s

          node.before(language_label)
          node.before(node.children).remove
        end

        css('div.sphinx-tabs [role="tablist"]').remove

        # remove the remotely hosted "percent-translated" badge
        css('a[href^="https://hosted.weblate"]').remove if root_page?

        doc
      end
    end
  end
end
