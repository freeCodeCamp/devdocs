module Docs
  class Statsmodels
    class EntriesFilter < Docs::EntriesFilter
      # A couple of statsmodels.tools pages are only linked from the
      # introductory chapters.
      TYPE_ALIASES = {
        'Getting started' => 'Tools',
        'About statsmodels' => 'Tools'
      }.freeze

      def get_name
        if subpath.start_with?('generated')
          node = at_css('dt')
          node.css('.headerlink').remove
          name = node.content.strip
          name.sub! %r{\(.*}m, '()' # Remove method arguments
          name.remove! %r{[\=\[].*} # Remove "[source]"
          name.remove! %r{\A(class(method)?|exception|property|static) }
          name.remove! %r{\Astatsmodels\.}
        else
          node = at_css('h1', 'h2')
          node.css('.headerlink').remove
          # Chapter titles end with the module name, e.g. "Statistics <code>stats</code>"
          if (code = node.at_css('code')) && node.content.strip.end_with?(code.content.strip)
            code.remove
          end
          name = node.content.strip
          name.prepend 'Manual: ' if type == 'Manual'
          name.prepend 'Example: ' if type == 'Examples'
        end
        name.remove! "\u{00B6}" # Remove ¶
        name
      end

      def get_type
        if subpath.start_with?('generated')
          # The breadcrumbs read "User Guide > <chapter> [> <class>] > <object>",
          # where the chapter link reads e.g. "Statistics <code>stats</code>".
          crumbs = css('.bd-breadcrumbs .breadcrumb-item:not(.breadcrumb-home):not(.active) a').map do |node|
            node.css('code').remove
            node.content.strip
          end
          crumbs.delete('User Guide')
          TYPE_ALIASES.fetch(crumbs.first, crumbs.first) || api_type
        elsif subpath.start_with?('examples')
          'Examples'
        else
          'Manual'
        end
      end

      private

      # Pages that aren't reachable from a user guide chapter, such as the
      # statsmodels.api aliases, are typed after their module.
      def api_type
        subpath[%r{\Agenerated/statsmodels\.([\w\.]+?)\.\w+\.html\z}, 1] || 'statsmodels'
      end
    end
  end
end
