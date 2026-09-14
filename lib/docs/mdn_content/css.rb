require 'cgi'

module Docs
  module MdnContent
    # The two sections MDN generates out of mdn-data on the pages of the CSS
    # reference: the formal syntax of a property, type, function or at-rule,
    # and the table of its characteristics below it.
    #
    # MDN expands and aligns the syntax with css-tree; this prints the same
    # definitions, one alternative per line, without the alignment and without
    # linking every multiplier to the page explaining it. See
    # kumascript/src/lib/css-syntax.ts in https://github.com/mdn/yari.
    class Css
      REFERENCE = '/en-US/docs/Web/CSS/Reference'

      # How deep the definitions of the types a syntax refers to are followed.
      # MDN stops when it runs out of definitions; the limit is a guard against
      # the types that refer back to each other.
      DEPTH = 10

      # The rows of the characteristics table, and the order MDN puts them in.
      CHARACTERISTICS = {
        'initial' => 'Initial value',
        'appliesto' => 'Applies to',
        'inherited' => 'Inherited',
        'percentages' => 'Percentages',
        'computed' => 'Computed value',
        'animationType' => 'Animation type'
      }.freeze

      # A reference to the definition of a type, e.g. <color> or
      # <integer [0,∞]>. The references to a property are quoted —
      # <'animation-name'> — which is why they don't match.
      TYPE = /<([\w-]+(?:\(\))?)(?:\s*\[[^\]]*\])?>/

      # The same reference to a property, once escaped.
      PROPERTY = /&lt;&#39;([\w-]+)&#39;&gt;/

      # The combinators a definition is broken into lines on, outside of any
      # brackets.
      COMBINATOR = /\s(\|\||&&|\||\s)\s/

      def initialize(data)
        @data = data
      end

      # The formal syntax of the thing a page documents, followed by the
      # definitions of the types it's made of.
      def syntax(page)
        name, syntax = definition(page)
        return if syntax.blank?

        blocks = [[name, syntax]]
        seen = [name]
        pending = [syntax]

        DEPTH.times do
          pending = pending.flat_map { |value| references(value) }.uniq
          pending -= seen
          pending = pending.filter_map do |reference|
            next unless (value = @data.css_syntax(reference))
            seen << reference
            blocks << ["<#{reference}>", value]
            value
          end
          break if pending.empty?
        end

        %(<pre class="css-formal-syntax">#{blocks.map { |block| render(*block) }.join("\n")}</pre>)
      end

      def raw_syntax(syntax)
        %(<pre class="css-formal-syntax">#{escape syntax.delete('`')}</pre>)
      end

      # The table of the characteristics of a property or an at-rule
      # descriptor, e.g. whether it's inherited and how it animates.
      def info(page, name = nil, at_rule = nil)
        return unless (entry = characteristics(page, name, at_rule))

        rows = CHARACTERISTICS.filter_map do |key, label|
          value = entry[key]
          next if value.nil? || value == '' || (key == 'percentages' && value == 'no')
          %(<tr><th scope="row">#{label}</th><td>#{value_html value}</td></tr>)
        end

        return if rows.empty?
        %(<table class="properties"><tbody>#{rows.join}</tbody></table>)
      end

      private

      # The name a page documents and the syntax of its definition, both of
      # which depend on what kind of page it is.
      def definition(page)
        name = page.slug.split('/').last.downcase

        case page.page_type
        when 'css-property', 'css-shorthand-property'
          [name, @data.css('properties', name)&.fetch('syntax', nil)]
        when 'css-type'
          name = name.delete_suffix('_value')
          [+"<#{name}>", @data.css_syntax(name) || @data.css('types', name)&.fetch('syntax', nil)]
        when 'css-function'
          [+"<#{name}()>", @data.css_syntax("#{name}()") || @data.css('functions', "#{name}()")&.fetch('syntax', nil)]
        when 'css-at-rule'
          [+"@#{name}", @data.css('at-rules', "@#{name}")&.fetch('syntax', nil)]
        when 'css-at-rule-descriptor'
          [name, descriptor(page, name)&.fetch('syntax', nil)]
        else
          [name, nil]
        end
      end

      def characteristics(page, name, at_rule)
        name ||= page.slug.split('/').last.downcase

        if at_rule.present? || page.page_type == 'css-at-rule-descriptor'
          descriptor page, name, at_rule
        else
          @data.css 'properties', name
        end
      end

      # An at-rule descriptor is documented one level below its at-rule.
      def descriptor(page, name, at_rule = nil)
        at_rule ||= "@#{page.slug.split('/')[-2].to_s.downcase}"
        at_rule = "@#{at_rule}" unless at_rule.start_with?('@')
        @data.css('at-rules', at_rule)&.dig('descriptors', name)
      end

      def render(name, syntax)
        lines = split(syntax).map { |line| "  #{markup line}" }
        "<span class=\"token property\">#{escape name} = </span>\n#{lines.join("\n")}\n"
      end

      # Breaks a definition on the combinators that aren't inside brackets, the
      # way MDN lays it out.
      def split(syntax)
        lines = ['']
        depth = 0

        syntax.split(/(?<=[\s\[\]])|(?=[\[\]])/).each do |token|
          depth += token.count('[') - token.count(']')
          lines.last << token
          lines << '' if depth.zero? && token.match?(/\A\s*(\|\||&&|\|)\s*\z/)
        end

        lines.map(&:strip).reject(&:empty?)
      end

      # The references to a property are the only ones worth a link: the types
      # are spelled out right below.
      def markup(line)
        escape(line).gsub(PROPERTY) { %(<a href="#{REFERENCE}/Properties/#{$1}">&lt;'#{$1}'&gt;</a>) }
      end

      def references(syntax)
        syntax.scan(TYPE).flatten
      end

      # A shorthand takes its value from every property it stands for; the
      # rest read as a string, or as one of the values mdn-data enumerates.
      def value_html(value)
        case value
        when true then 'yes'
        when false then 'no'
        when Array
          items = value.map { |name| "<li>#{link name}</li>" }
          %(as each of the properties of the shorthand:<ul>#{items.join}</ul>)
        else
          escape(@data.css_string(value) || value)
        end
      end

      def link(name)
        %(<a href="#{REFERENCE}/Properties/#{name}"><code>#{escape name}</code></a>)
      end

      def escape(text)
        CGI.escape_html text.to_s
      end
    end
  end
end
