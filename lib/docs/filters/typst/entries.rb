module Docs
  class Typst
    class EntriesFilter < Docs::EntriesFilter
      NAMESPACES = %w(math pdf html).freeze

      def get_name
        heading = at_css('main h1') || raise("missing h1 on #{current_url}")
        definition = definition_node(heading)
        return heading.content.strip unless definition

        prefix = NAMESPACES.include?(category) ? "#{category}." : ''
        suffix = definition.name == 'code' ? '()' : ''
        "#{prefix}#{definition.content.strip}#{suffix}"
      end

      def get_type
        return 'Language' if %w(syntax styling scripting context).include?(category)
        return name if slug.split('/').length == 1

        crumb = at_css('.breadcrumbs li:nth-last-child(3) a')
        raise "missing category breadcrumb on #{current_url}" unless crumb
        crumb.content.strip
      end

      def additional_entries
        return [] if root_page?

        entries = css('main .scoped-definition').map do |node|
          # Definitions belong to a type/function (array.map, table.cell).
          # Grouped functions and constants belong to a module (calc.abs, math.upright).
          prefix = node['id'].start_with?('definitions-') ? name.delete_suffix('()') : namespace
          # Nested types, such as color.spot, have their own definitions.
          scopes = node['id'].split('-definitions-')[0...-1]
          scopes.map! { |scope| scope.sub(/\A(?:definitions|functions)-/, '') }
          prefix = ([prefix] + scopes).join('.')
          definition = definition_node(node)
          raise "missing name in ##{node['id']} on #{current_url}" unless definition
          suffix = definition.name == 'code' && function_definition?(node) ? '()' : ''
          ["#{prefix}.#{definition.content.strip}#{suffix}", node['id']]
        end

        css('main h3[id^="parameters-"] > code').each do |node|
          entries << ["#{name.delete_suffix('()')}.#{node.content.strip}", node.parent['id']]
        end

        if category == 'symbols'
          css('.symbol-grid li[id]').each do |node|
            entries << ["#{slug.split('/').last}.#{symbol_name(node)}", node['id']]
          end
        elsif type == 'Language'
          css('main h2[id]').each do |node|
            entries << ["#{name}: #{node.content.strip}", node['id']]
          end
        end

        entries
      end

      private

      def category
        slug.split('/').first
      end

      def namespace
        NAMESPACES.include?(category) ? category : slug.split('/').last
      end

      def definition_node(heading)
        heading.at_css('> code') || heading.at_css('> .pill')
      end

      def symbol_name(node)
        code = node.at_css('code')
        raise "missing name for ##{node['id']} on #{current_url}" unless code
        code.content
      end

      def function_definition?(node)
        sibling = node.next_element
        while sibling && !sibling.name.match?(/\Ah[1-6]\z/)
          return true if sibling['class'].to_s.split.include?('code-definition')
          sibling = sibling.next_element
        end
        false
      end
    end
  end
end
