module Docs
  class Haskell
    class CleanHtmlFilter < Filter
      def call

        # remove unwanted elements
        css('#footer', '#package-header', '#module-header', '#synopsis', '.link', '#table-of-contents', '.show .empty', '.package').remove

        css('pre').each do |node|
          node.add_css_class('example')
        end

        # cpations in tables are h3
        css('table .caption').each do |node|
          node.name = 'h3'
        end

        # turn captions into real headers
        css('.caption').each do |node|
          node.name = 'h1'
        end

        css('.top > .caption').each do |node|
          node.name = 'h2'
        end

        # subsections
        css('.top > .subs > .caption', '.fields > .caption').each do |node|
          node.name = 'h3'
        end

        # subsubsections
        css('.top > .subs > .subs > .caption').each do |node|
          node.name = 'h4'
        end

        css('.top > .subs > .subs > .subs > .caption').each do |node|
          node.name = 'h5'
        end

        css('.top > .subs > .subs > .subs > .subs > .caption').each do |node|
          node.name = 'h6'
        end

        # turn source listing in to pre
        css('.src').each do |node|
          if node.name == "td"
            # pre = doc.create_element 'pre'
            # pre.children = node.children
            # node.children = [pre]
          else
            node.name = 'pre'
          end
        end

        if at_css('h1') && at_css('h1').content == 'Haskell Hierarchical Libraries'
          css('h1').remove
        end

        css('a').each do |node|
          if node['name']
            node['id'] = node['name']
          end
        end

        css('.caption').each do |node|
          if node.content == 'Arguments'
            node.remove
          end
        end

        # add some informational boxes
        css('em').each do |node|
          if node.content == 'Deprecated.'
            # Make deprecated messages red.
            node.parent.add_css_class('warning')
          elsif node.content =~ /O\(.*\)/
            # this is big_O notation, but only apply the class if this is not
            # inside running text (it must be at the start of a paragraph)
            # from:
            # <p><em>O(n)</em>. Koel ok</p>
            # to:
            # <p class="with-complexity">
            #   <span class="complexity">O(n)</span>
            #   <span>Koel ok</span>
            # </p>
            if node.previous == nil
              node.add_css_class('complexity')                        # add css class
              node.name="span"                                         # just make it div
              node.next.content = node.next.content.gsub(/^. /, "") # remove . if directly after em
              node.content = node.content.gsub(/\.$/, "")             # remove trailing . if it's inside em

              # reparent the nodes
              cont = doc.document.create_element "p", :class => "with-complexity"
              node.parent.previous = cont
              par = node.parent
              node.parent = cont
              par.parent = cont
              par.name = "span"
            end
          elsif node.content =~ /Since: .*/
            # add box to 'Since:' annotations
            node.add_css_class('added')
          end
        end

        doc
      end
    end
  end
end

class Nokogiri::XML::Node
  def add_css_class( *classes )
    existing = (self['class'] || "").split(/\s+/)
    self['class'] = existing.concat(classes).uniq.join(" ")
  end
end
