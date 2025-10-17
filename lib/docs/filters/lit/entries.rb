module Docs
  class Lit
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name = at_css('h1').content.strip
      end

      def get_type
        # The type/category is section name from the sidebar.
        active = at_css('#docsNav details li.active')
        return nil unless active
        summary = active.ancestors('details').first.at_css('summary')
        return nil unless summary
        summary.css('[aria-hidden="true"]').remove
        summary.content.strip
      end

      def additional_entries
        entries = []

        # Code for the API reference pages (and other similar pages).
        scope_name = ''
        css('.heading > h2[id], .heading > h3[id], .heading > h4[id]').each do |node|
          name = node.content.strip
          id = node['id']
          # The kindTag has these values:
          # class, decorator, directive, function, namespace, type, value
          kind = node.parent.at_css('.kindTag')&.content&.strip

          if kind
            # Saving the current "scope", i.e. the current class name.
            # This is useful to prefix the method/property names, which are defined after this element.
            scope_name = name
            name = kind + " " + name
          else
            # If this is a method/property, it has a different markup.
            # Let's extract them and add a prefix for disambiguation.
            function = node.at_css('.functionName')
            property = node.at_css('.propertyName')
            if function
              # Note how "functions" are actually "methods" of some class.
              # Bare (top-level) functions are extracted when `.kindTag` is "function".
              name = scope_name + '.' + function.content.strip
              kind = 'method'
            elsif property
              name = scope_name + '.' + property.content.strip
              kind = 'property'
            end
          end

          # If we couldn't figure out the kind, this is a header tag that we can ignore.
          entries << [name, id, kind] if kind
        end

        # Code for the Built-in Directives page.
        # This page has a TOC of the built-in directives, with a clear documentation of each one.
        # Note that the directives are also indexed in the API reference pages.
        # Yes, each directive is indexed twice, because each one is documented twice.
        css('.directory a[href^="#"]').each do |node|
          name = node.content.strip
          id = node['href'].sub /^#/, ''
          # type will be "Built-in directives"
          type = node.ancestors('article').at_css('h1').content.strip
          entries << [name, id, type]
        end

        entries
      end
    end
  end
end
