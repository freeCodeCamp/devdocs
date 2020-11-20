module Docs
  class Pytorch
    class CleanHtmlFilter < Filter
      def call
        breadcrumbs = at_css('.pytorch-breadcrumbs')
        type_name = breadcrumbs.css('li')[1].content

        @doc = at_css('.pytorch-article')
        # Show katex-mathml nodes and remove katex-html nodes
        css('.katex-html').remove

        # pass type_name to following filters as a new node
        node = Nokogiri::XML::Node.new 'meta', doc
        node.content = type_name
        doc.child.before node

        doc
      end
    end
  end
end
