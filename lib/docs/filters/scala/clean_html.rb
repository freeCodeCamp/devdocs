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
        # Some of this is just for 2.12
        # These are things that provide interactive features, which are not supported yet.
        css('#subpackage-spacer, #search, #mbrsel, .diagram-btn').remove
      end

      def root
        css('#filter').remove # these are filters to search through the types and packages
        css('#library').remove # these are icons at the top
        doc
      end

      def other
        # these are sections of the documentation which do not seem useful
        %w(#inheritedMembers #groupedMembers).each do |selector|
          css(selector).remove
        end

        # This is the kind of thing we have, class, object, trait
        el_kind = at_css('.modifier_kind .kind')
        begin
          kind = el_kind.content
          # this image replacement doesn't do anything on 2.12 docs
          img = at_css('img')
          img.replace %Q|<span class="img_kind">#{kind}</span>| unless img.nil?
          class_to_add = kind == 'object' ? 'value': 'type'
        end if el_kind

        # for 2.10, 2.11, the kind class is associated to the body. we have to
        # add it somewhere, so we do that with the #definition.
        css('#definition').add_class class_to_add

        doc
      end
    end
  end
end
