module Docs
  class Scala
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#content')

        always
        add_title

        doc
      end

      def always
        # Remove deprecated sections
        css('.members').each do |members|
          header = members.at_css('h3')
          members.remove if header.text.downcase.include? 'deprecate'
        end

        css('#mbrsel, #footer').remove

        css('.diagram-container').remove
        css('.toggleContainer > .toggle').each do |node|
          title = node.at_css('span')
          next if title.nil?

          content = node.at_css('.hiddenContent')
          next if content.nil?

          title.name = 'dt'

          content.remove_attribute('class')
          content.remove_attribute('style')
          content.name = 'dd'

          attributes = at_css('.attributes')
          unless attributes.nil?
            title.parent = attributes
            content.parent = attributes
          end
        end

        signature = at_css('#signature')
        signature.replace "<h2 id=\"signature\">#{signature.inner_html}</h2>"

        css('div.members > h3').each do |node|
          node.name = 'h2'
        end

        css('div.members > ol').each do |list|
          list.css('li').each do |li|
            h3 = doc.document.create_element 'h3'
            h3['id'] = li['name'].rpartition('#').last unless li['name'].nil?

            li.prepend_child h3
            li.css('.shortcomment').remove

            modifier = li.at_css('.modifier_kind')
            modifier.parent = h3 unless modifier.nil?

            kind = li.at_css('.modifier_kind .kind')
            kind.content = kind.content + ' ' unless kind.nil?

            symbol = li.at_css('.symbol')
            symbol.parent = h3 unless symbol.nil?

            li.swap li.children
          end

          list.swap list.children
        end

        css('.fullcomment pre, .fullcommenttop pre').each do |pre|
          pre['data-language'] = 'scala'
          pre.content = pre.content
        end

        # Sections of the documentation which do not seem useful
        %w(#inheritedMembers #groupedMembers .permalink .hiddenContent .material-icons).each do |selector|
          css(selector).remove
        end

        # Things that are not shown on the site, like deprecated members
        css('li[visbl=prt]').remove
      end

      def add_title
        css('.permalink').remove

        definition = at_css('#definition')
        return if definition.nil?

        type_full_name = {a: 'Annotation', c: 'Class', t: 'Trait', o: 'Object', p: 'Package'}
        type = type_full_name[definition.at_css('.big-circle').text.to_sym]
        name = CGI.escapeHTML definition.at_css('h1').text

        package = definition.at_css('#owner').text rescue ''
        package = package + '.' unless name.empty? || package.empty?

        other = definition.at_css('.morelinks').dup
        other_content = other ? "<h3>#{other.to_html}</h3>" : ''

        title_content = root_page? ? 'Package root' : "#{type} #{package}#{name}".strip
        title = "<h1>#{title_content}</h1>"
        definition.replace title + other_content
      end
    end
  end
end
