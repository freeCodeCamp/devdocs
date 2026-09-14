module Docs
  class MdnGit
    # Expands the KumaScript macro calls MDN leaves in its markdown.
    class MacrosFilter < Filter
      # A macro can expand into another one: the tables MDN builds out of its
      # own data are written with the same cross-references as its prose. Two
      # rounds are enough for those, the third is a stop.
      PASSES = 3

      def call
        macros = MdnContent::Macros.new context[:page], context[:pages], context[:generator]
        PASSES.times { break unless expand(macros) }
        doc
      end

      private

      def expand(macros)
        expanded = false

        # A macro call in a code block is quoted rather than called, as on the
        # page documenting the "Regular expression syntax error". The calls in
        # the code that runs through the prose are expanded like any other.
        xpath('.//text()[not(ancestor::pre)]').each do |node|
          next unless macros.expand?(node.content)
          html = macros.expand(node.content)
          node = paragraph_of(node) if macros.block?(html)
          html.empty? ? node.remove : node.replace(html)
          expanded = true
        end

        expanded
      end

      # The paragraph a macro that renders to a block of its own sits in, which
      # it replaces instead of nesting itself into.
      def paragraph_of(node)
        parent = node.parent
        return node unless parent&.name == 'p'
        return node unless parent.children.all? { |child| child == node || (child.text? && child.content.strip.empty?) }
        parent
      end
    end
  end
end
