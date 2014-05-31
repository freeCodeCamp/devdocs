module Docs
  class Haskell
    class CleanHtmlFilter < Filter
      def call

        # remove unwanted elements
        css('#footer', '#package-header', '#module-header', '#synopsis', '.link', '#table-of-contents', '.package').remove

        # cpations in tables are h3
        css('table .caption').each do |node|
          node.name = 'h3'
        end

        # turn captions into real headers
        css('.caption').each do |node|
          node.name = 'h1'
        end

        # section
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

        # ...
        css('.top > .subs > .subs > .subs > .caption').each do |node|
          node.name = 'h5'
        end

        # ......
        css('.top > .subs > .subs > .subs > .subs > .caption').each do |node|
          node.name = 'h6'
        end

        # all pre's are examples
        css('pre').each do |node|
          node.add_css_class('example')
        end

        # turn source listing in to pre
        css('.src').each do |node|
          if node.name != "td"
            node.name = 'pre'
          end
        end

        # check if second column of table is totally empty.
        # and remove it if it is
        css('table').each do |table|
          empty = true
          table.css('td + td').each do |snd|
            empty = empty && snd['class'] =~ /empty/
          end
          if empty
            # remove empty column
            table.css('td + td').remove
          end
        end

        # move table captions into the tables
        css(".caption + table").each do |table|
          caption = table.previous
          caption.name = "caption"
          caption.parent = table
        end

        css(".caption + .show table").each do |table|
          caption = table.parent.parent.css('.caption')[0]
          caption.name = 'caption'
          caption.parent = table
        end

        # better arguments display:
        css('.src + .arguments table').each do |table|
          src = table.parent.previous # the function name
          row = doc.document.create_element('tr')
          table.css('tr')[0].before(row)
          src.parent = row
          src.name = "th"
          src['colspan'] = 2
        end

        # remove root page title
        if root_page?
          at_css('h1').remove
        end

        # add id to links (based on name)
        css('a').each do |node|
          if node['name']
            node['id'] = node['name']
          end
        end

        # make code in description into proper pre
        css('dd > code').each do |node|
          node.name = 'pre'
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
              node.name="span"                                        # just make it div
              node.next.content = node.next.content.gsub(/^. /, "")   # remove . if directly after em
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
            if node.parent.parent.name == "td"
              node.parent.parent.add_css_class('added-cell')
            else
              node.add_css_class('added')
            end
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
