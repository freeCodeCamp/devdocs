module Docs
  class MdnGit
    # Turns the HTML of the rendered markdown into the HTML MDN publishes: the
    # definition lists and the note cards its authors write in markdown, and
    # the ids its pages link their sections by.
    class CleanHtmlFilter < Filter
      # MDN's h1 carries the title of the page, which nothing links to.
      SECTIONS = 'h2, h3, h4, h5, h6, dt'

      DEFINITION = ': '

      # https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts
      ALERTS = {
        'NOTE' => ['note', 'Note'],
        'WARNING' => ['warning', 'Warning'],
        'IMPORTANT' => ['note', 'Important'],
        'TIP' => ['note', 'Tip'],
        'CAUTION' => ['warning', 'Caution']
      }

      ALERT = /\A\s*\[!([A-Z]+)\]\s*/

      def call
        definition_lists
        note_cards
        code_blocks
        section_ids
        tables
        empty_paragraphs
        doc
      end

      private

      # MDN writes its definition lists as lists whose every item is a term
      # followed by a one-item list holding the definition, prefixed with a
      # colon. See markdown/m2h/handlers/dl.ts in https://github.com/mdn/yari.
      def definition_lists
        # Innermost first, so that a nested list is a <dl> by the time the one
        # around it is looked at and can no longer be taken for a definition.
        css('ul').to_a.reverse_each do |list|
          next unless definition_list?(list)
          list.name = 'dl'
          list.element_children.each { |item| replace_with_definition(item) }
        end
      end

      def definition_list?(list)
        items = list.element_children
        items.any? && items.all? do |item|
          definitions = item.element_children.last
          next false unless definitions && definitions.name == 'ul' && item.children.size > 1
          next false unless definitions.element_children.size == 1
          definition?(definitions.element_children.first)
        end
      end

      def definition?(item)
        leading_text(item).to_s.lstrip.start_with?(DEFINITION)
      end

      def replace_with_definition(item)
        definitions = item.element_children.last
        definition = definitions.element_children.first

        term = Nokogiri::XML::Node.new('dt', item.document)
        item.children.to_a.take_while { |child| child != definitions }.each { |child| term << child }

        described = Nokogiri::XML::Node.new('dd', item.document)
        definition.children.to_a.each { |child| described << child }
        remove_definition_prefix described

        item.add_previous_sibling term
        item.replace described
      end

      def remove_definition_prefix(node)
        return unless (text = leading_text_node(node))
        text.content = text.content.lstrip.delete_prefix(DEFINITION)
      end

      def leading_text(node)
        leading_text_node(node)&.content
      end

      def leading_text_node(node)
        node.xpath('.//text()').find { |text| text.content.present? && !text.content.strip.empty? }
      end

      # GitHub's alerts, which MDN renders as its note cards.
      def note_cards
        css('blockquote').each do |quote|
          next unless (text = leading_text_node(quote))
          next unless (alert = text.content.match(ALERT))
          next unless (name, title = ALERTS[alert[1]])

          text.content = text.content.sub(ALERT, '')
          (quote.at_css('p') || quote).prepend_child %(<strong>#{title}:</strong> )

          quote.name = 'div'
          quote['class'] = "notecard #{name}"
        end
      end

      def code_blocks
        css('pre > code').each do |code|
          pre = code.parent
          language = code['class'].to_s[/language-(\S+)/, 1]
          pre['data-language'] = language if language
          pre.content = code.content
        end
      end

      # MDN gives every heading and every term an id, which is what the links
      # to a section of a page point at. See kumascript/src/api/util.ts in
      # https://github.com/mdn/yari.
      def section_ids
        taken = Set.new

        css(SECTIONS).each do |node|
          term = node.name == 'dt'
          id = node['id']&.downcase

          if id.blank?
            # A term can be followed by a badge, which isn't part of its name.
            text = term ? node.element_children.first&.content || node.content : node.content
            id = MdnContent.slugify(text)
            id = "#{id}_#{taken.size}" if id.blank?
            id = (2..).lazy.map { |count| "#{id}_#{count}" }.find { |candidate| !taken.include?(candidate) } if taken.include?(id)
          end

          taken << id
          node['id'] = id

          next unless term
          first = node.element_children.first
          next if first.nil? || first.name == 'a' || first.at_css('a')
          first.replace %(<a href="##{id}">#{first.to_html}</a>)
        end
      end

      def tables
        css('table').each do |table|
          table.before %(<div class="_table"></div>)
          table.previous_element << table
        end
      end

      # Left behind by the macros that don't render to anything, e.g. {{JSRef}}.
      def empty_paragraphs
        css('p').each { |node| node.remove if node.content.strip.empty? && node.element_children.empty? }
      end
    end
  end
end
