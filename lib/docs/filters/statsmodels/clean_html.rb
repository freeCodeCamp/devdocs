module Docs
  class Statsmodels
    class CleanHtmlFilter < Filter
      def call
        # The container keeps the whole main column so that EntriesFilter can
        # read the breadcrumbs; only the article is documentation.
        @doc = at_css('article.bd-article') || doc

        css('.bd-sidebar-secondary', '.bd-toc', '.prev-next-area', '.prev-next-footer', '.bd-footer', 'form').remove

        # "[source]" links point to the module sources, which aren't scraped.
        css('a:has(.viewcode-link)').remove

        if root_page?
          at_css('h1').content = 'Statsmodels'
          css('#index').remove
        end

        # Parameter lists render as "name" followed by its type in a classifier
        # span; separate them before Sphinx::CleanHtmlFilter flattens the <dt>.
        css('dt > .classifier').each do |node|
          node.before(': ')
        end

        # Notebook pages (nbsphinx): drop the "In [1]:" prompts, keep the input
        # cells for Sphinx::CleanHtmlFilter (they're "highlight-ipython3"
        # blocks) and turn the outputs into plain <pre> blocks.
        css('.nbinput .prompt', '.nboutput .prompt').remove
        css('.output_area div.highlight').each do |node|
          pre = node.at_css('pre')
          pre.content = pre.content
          node.replace(pre)
        end
        css('.nbinput', '.nboutput', '.output_area', 'div.cell', 'div.inner_cell', 'div.text_cell_render').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
