module Docs
  class Scala
    class CleanHtmlFilter < Filter
      def call
        always

        if slug == 'index'
          root
        else
          other
        end
      end

      def always
        # remove deprecated sections
        css('.members').each do |members|
          header = members.at_css('h3')
          members.remove if header.text.downcase.include? 'deprecate'
        end
        # Some of this is just for 2.12
        # These are things that provide interactive features, which are not supported yet.
        css('#subpackage-spacer, #search, #mbrsel, .diagram-btn').remove
        css('#footer').remove
        css('.toggleContainer').remove

        signature = at_css('#signature')
        signature.replace %Q|
          <h2 id="signature">#{signature.inner_html}</h2>
        |

        css('div.members > h3').each do |node|
          change_tag! 'h2', node
        end

        css('div.members > ol').each do |list|
          list.css('li').each do |li|
            h3 = doc.document.create_element 'h3'
            li.prepend_child h3
            li.css('.shortcomment').remove
            modifier = li.at_css('.modifier_kind')
            modifier.parent = h3 if modifier
            symbol = li.at_css('.symbol')
            symbol.parent = h3 if symbol
            li.swap li.children
          end
          list.swap list.children
        end

        pres = css('.fullcomment pre, .fullcommenttop pre')
        pres.each do |pre|
          pre['data-language'] = 'scala'
        end
        pres.add_class 'language-scala'



        doc

      end

      def root
        css('#filter').remove # these are filters to search through the types and packages
        css('#library').remove # these are icons at the top
        doc
      end

      def other
        # these are sections of the documentation which do not seem useful
        %w(#inheritedMembers #groupedMembers .permalink .hiddenContent .material-icons).each do |selector|
          css(selector).remove
        end

        # This is the kind of thing we have, class, object, trait
        kind = at_css('.modifier_kind .kind').content
        # this image replacement doesn't do anything on 2.12 docs
        img = at_css('img')
        img.replace %Q|<span class="img_kind">#{kind}</span>| unless img.nil?
        class_to_add = kind == 'object' ? 'value': 'type'

        # for 2.10, 2.11, the kind class is associated to the body. we have to
        # add it somewhere, so we do that with the #definition.
        definition = css('#definition')
        definition.css('.big_circle').remove
        definition.add_class class_to_add

        # this is something that is not shown on the site, such as deprecated members
        css('li[visbl=prt]').remove

        doc
      end

      private

      def change_tag!(new_tag, node)
        node.replace %Q|<#{new_tag}>#{node.inner_html}</#{new_tag}>|
      end
    end
  end
end
