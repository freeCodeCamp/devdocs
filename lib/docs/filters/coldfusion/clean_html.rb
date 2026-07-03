module Docs
  class Coldfusion
    class CleanHtmlFilter < Filter
      def call
        # Listing/category pages (Tags, Functions, a category, or a guide index)
        # use a different layout; keep their main container as-is after cleanup.
        @doc = build_root

        # Remove site chrome and interactive widgets.
        css('nav', 'footer', 'script', 'noscript', '#cfbreak', '.newsletter').remove
        css('.modal', '.add-example-modal-lg', '.example-modal').remove
        css('.example-btn', '.copy-btn', '.issuebutton', '.issuecount').remove
        css('button').remove

        # Drop the "Add An Example" / edit / fork affordances.
        css('a[href*="github.com"]', '#forkme', '#foundeo').remove
        css('a.label.label-danger').remove # Edit links

        # Clean up the breadcrumb: keep the engine-version labels (they convey
        # ColdFusion/Lucee/BoxLang availability) but drop navigation links and
        # the issue tracker widget.
        if (crumb = at_css('.breadcrumb'))
          crumb.css('.label-warning').remove
          crumb.css('.divider').remove
          crumb.css('a[rel="nofollow"]').remove
          # Remove navigation breadcrumb items (CFDocs > Functions > cf45 > …)
          # that are not engine-availability labels.
          crumb.css('li:not(.pull-right)').each do |li|
            li.remove unless li.at_css('.label-acf, .label-lucee, .label-boxlang, .label-railo')
          end
        end

        # Code blocks: tag them so DevDocs applies CFML syntax highlighting.
        css('pre.prettyprint', 'pre').each do |node|
          node.remove_attribute('class')
          node['data-language'] = 'coldfusion'
        end

        # Inline code: nothing special needed, but strip prettyprint hints.
        css('code').each { |node| node.remove_attribute('class') }

        # Unwrap Bootstrap `.container` layout wrappers; DevDocs supplies its own
        # page width, so these only add centering/padding we don't want.
        css('.container').each { |node| node.before(node.children).remove }

        # Remove now-empty wrappers left behind by the source template's many
        # conditional blank lines.
        css('div', 'p', 'span', 'ul', 'ol').each do |node|
          node.remove if node.inner_html.strip.empty? && node.element_children.empty?
        end

        doc
      end

      # cfdocs splits an entry's content across the `.jumbotron` header (name,
      # description, syntax), the `.breadcrumb`, and the main `.container`
      # (arguments, compatibility, links, examples). Merge them into one root.
      #
      # NOTE: between filters the document is re-parsed as an HTML *fragment*
      # (there is no <body>), so selectors must not depend on `body >`.
      def build_root
        # First .jumbotron is the page header; #cfbreak is the trailing
        # newsletter jumbotron, which we ignore.
        header = css('.jumbotron').reject { |n| n['id'] == 'cfbreak' }
                                  .map { |n| n.at_css('.container') || n }
                                  .first
        breadcrumb = at_css('.breadcrumb')

        # The main content container holds the reference sections. It is a
        # `.container` that is not the breadcrumb and not inside a jumbotron or
        # nav. Identify it by the section headings it contains.
        main = css('.container').find do |node|
          next false if node.matches?('.breadcrumb')
          next false if node.ancestors('.jumbotron').any? || node.ancestors('nav').any?
          node.at_css('h2, .param, .panel') || node.at_css('#examples')
        end

        root = Nokogiri::HTML.fragment('<div></div>').at_css('div')
        root << header.dup if header
        root << breadcrumb.dup if breadcrumb
        root << main.dup if main

        # Fall back to the full document/fragment if the expected structure is
        # missing (e.g. some guide pages).
        root.element_children.any? ? root : (at_css('body') || doc)
      end
    end
  end
end
