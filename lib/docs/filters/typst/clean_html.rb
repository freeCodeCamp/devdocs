module Docs
  class Typst
    class CleanHtmlFilter < Filter
      def call
        # The container keeps the sidebar so internal_urls can crawl it.
        # Once we have collected all links, we keep only the page body.
        @doc = at_css('main') || raise("missing main on #{current_url}")

        css('.breadcrumbs', '.page-end-buttons', '.sources-link', '.tooltip-context',
            '.search', 'button.copy').remove

        # Category lists rely on CSS columns to separate names and descriptions.
        # We separate them with an em-dash to make them readable.
        css('.catgrid > li > a + span').each { |node| node.before(' — ') }

        # Adjacent type pills are unions, separated visually by the site's CSS.
        css('.pill + .pill').each { |node| node.before(' or ') }

        # Parameter types, modifiers, and defaults live inside headings.
        # Move them into a paragraph so headings stay readable.
        css('h1, h2, h3, h4, h5, h6').each do |heading|
          heading.css('> .additional-info', '> small').reverse_each do |node|
            node.css('small.mod').each { |modifier| modifier.after(' ') }
            node.css('> div').each do |types|
              types.name = 'span'
              types.after(' ')
            end
            node.name = 'p'
            heading.after(node)
          end
        end

        css('pre').each do |node|
          code = node.at_css('> code')
          language = code && code['data-lang']
          if language
            # Prism doesn't support Typst yet,
            # but we leave the language annotation in case it's implemented later.
            language = 'typst' if language.start_with?('typ')
            node['data-language'] = language == 'sh' ? 'bash' : language
          end
          node.content = node.content
        end

        css('.code-definition').each do |node|
          node.css('div.arguments .overview-param').each { |param| param.before("\n  ") }
          node.css('div.arguments').each do |args|
            args.add_child("\n")
            args.name = 'span'
          end
          node.name = 'pre'
        end

        # Open examples work without the source site's toggle scripts.
        css('details').each { |node| node['open'] = '' }
        css('summary img').remove

        # The original symbol picker needs JS to display character metadata.
        # A table retains every symbol and its anchor for offline lookup.
        css('.symbol-grid').each do |grid|
          table = Nokogiri::XML::Node.new('table', doc.document)
          table.inner_html = '<thead><tr><th>Name</th><th>Symbol</th><th>Unicode name</th><th>LaTeX</th></tr></thead><tbody></tbody>'
          body = table.at_css('tbody')
          grid.css('li[id]').each do |symbol|
            row = Nokogiri::XML::Node.new('tr', doc.document)
            row['id'] = symbol['id']
            name = symbol.at_css('code') || raise("missing name for ##{symbol['id']} on #{current_url}")
            code = Nokogiri::XML::Node.new('code', doc.document)
            code.content = name.content
            cell = Nokogiri::XML::Node.new('td', doc.document)
            cell.add_child(code)
            row.add_child(cell)
            [symbol['data-value'], symbol['data-unic-name']].each do |value|
              cell = Nokogiri::XML::Node.new('td', doc.document)
              cell.content = value.to_s
              row.add_child(cell)
            end
            cell = Nokogiri::XML::Node.new('td', doc.document)
            if symbol['data-latex-name'].present?
              latex = Nokogiri::XML::Node.new('code', doc.document)
              latex.content = symbol['data-latex-name']
              cell.add_child(latex)
            end
            row.add_child(cell)
            body.add_child(row)
          end
          grid.replace(table)
        end
        css('p:contains("Click on a")').each do |node|
          node.remove if node.content.include?('to copy it to the clipboard')
        end

        css('[class]', '[style]', '[aria-describedby]', '[data-lang]').each do |node|
          %w(class style aria-describedby data-lang).each { |attribute| node.remove_attribute(attribute) }
        end

        doc
      end
    end
  end
end
