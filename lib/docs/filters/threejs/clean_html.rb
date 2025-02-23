module Docs
  class Threejs
    class CleanHtmlFilter < Filter
      PATTERNS = {
        method_this: /\[method:this\s+([^\]]+)\]\s*\((.*?)\)/,
        method_return: /\[method:([^\s\]]+)\s+([^\]]+)\]\s*\((.*?)\)/,
        method_no_params: /\[method:([^\s\]]+)\s+([^\]]+)\](?!\()/,
        property: /\[property:([^\]]+?)\s+([^\]]+?)\]/,
        example_link: /\[example:([^\s\]]+)\s+([^\]]+)\]/,
        external_link_text: /\[link:([^\s\]]+)\s+([^\]]+)\]/,
        external_link: /\[link:([^\]]+)\]/,
        page_link_text: /\[page:([^\]]+?)\s+([^\]]+?)\]/,
        page_link: /\[page:([^\]]+?)\]/,
        inline_code: /`([^`]+)`/,
        name_placeholder: /\[name\]/,
        constructor_param: /\[param:([^\]]+?)\s+([^\]]+?)\]/
      }.freeze

      def call
        remove_unnecessary_elements
        wrap_code_blocks
        process_sections
        format_links
        add_section_structure
        format_notes
        add_heading_attributes
        doc
      end

      private

      def remove_unnecessary_elements
        css('head, script, style').remove
      end

      def wrap_code_blocks
        css('code').each do |node|
          next if node.parent.name == 'pre'
          node.wrap('<pre>')
          node.parent['data-language'] = 'javascript'
        end
      end

      def process_sections
        # Handle source links
        css('h2').each do |node|
          next unless node.content.strip == 'Source'
          node.next_element.remove
          node.remove
        end

        # Handle method signatures and properties
        css('h3').each do |node|
          content = node.inner_html
          content = handle_method_signatures(content)
          content = handle_properties(content)
          node.inner_html = content
        end

        # Handle name placeholders and constructor params
        css('h1, h3').each do |node|
          content = node.inner_html
          content = handle_name_placeholders(content)
          content = format_constructor_params(content)
          node.inner_html = content
        end
      end

      def handle_method_signatures(content)
        content
          .gsub(PATTERNS[:method_this]) { format_method_signature('this', $1, $2) }
          .gsub(PATTERNS[:method_return]) do |match|
            next if $2.start_with?('this')
            format_method_signature($1, $2, $3, true)
          end
          .gsub(PATTERNS[:method_no_params]) { format_method_signature($1, $2, nil, true) }
      end

      def format_method_signature(type_or_this, name, params_str, with_return = false)
        params = if params_str
          params_str.split(',').map { |param| format_parameter(param.strip) }.join("<span class='sig-paren'>, </span>")
        end

        html = "<dt class='sig sig-object js' id='#{name}'>"
        if type_or_this == 'this'
          html << "<span class='property'><span class='pre'>this</span></span>."
        end
        html << "<span class='sig-name descname'>#{name}</span>" \
               "<span class='sig-paren'>(</span>" \
               "#{params}" \
               "<span class='sig-paren'>)</span>"
        if with_return
          html << "<span class='sig-returns'><span class='sig-colon'>:</span> " \
                 "<span class='sig-type'>#{type_or_this}</span></span>"
        end
        html << "</dt>"
      end

      def format_parameter(param)
        if param.include?(' ')
          type, name = param.split(' ', 2).map(&:strip)
          "<span class='sig-param'><span class='sig-type'>#{type}</span> <span class='sig-name'>#{name}</span></span>"
        else
          "<span class='sig-param'>#{param}</span>"
        end
      end

      def handle_properties(content)
        content.gsub(PATTERNS[:property]) do |match|
          type, name = $1, $2
          "<dt class='sig sig-object js'>" \
          "<span class='sig-name descname'>#{name}</span>" \
          "<span class='sig-colon'>:</span> " \
          "<span class='sig-type'>#{type}</span></dt>"
        end
      end

      def handle_name_placeholders(content)
        content.gsub(PATTERNS[:name_placeholder]) do
          name = slug.split('/').last.gsub('.html', '')
          "<span class='descname'>#{name}</span>"
        end
      end

      def format_constructor_params(content)
        content.gsub(PATTERNS[:constructor_param]) do |match|
          type, name = $1, $2
          "<span class='sig-param'><span class='sig-type'>#{type}</span> <code class='sig-name'>#{name}</code></span>"
        end
      end

      def format_links
        css('*').each do |node|
          next if node.text?
          
          content = node.inner_html
            .gsub(PATTERNS[:example_link]) { create_external_link("https://threejs.org/examples/##{$1}", $2) }
            .gsub(PATTERNS[:external_link_text]) { create_external_link($1, $2) }
            .gsub(PATTERNS[:external_link]) { create_external_link($1, $1) }
            .gsub(PATTERNS[:page_link_text]) { create_internal_link($1, $2) }
            .gsub(PATTERNS[:page_link]) { create_internal_link($1, $1) }
          
          node.inner_html = content
        end

        normalize_href_attributes
      end

      def create_external_link(url, text)
        %Q(<a class='reference external' href='#{url}'>#{text}</a>)
      end

      def create_internal_link(path, text)
        %Q(<a class='reference internal' href='#{path.downcase}'><code class='xref js js-#{path.downcase}'>#{text}</code></a>)
      end

      def normalize_href_attributes
        css('a[href]').each do |link|
          next if link['href'].start_with?('http')
          link['href'] = link['href'].remove('../').downcase.sub(/\.html$/, '')
          link['class'] = 'reference internal'
        end
      end

      def add_section_structure
        css('h2').each do |node|
          node['class'] = 'section-title'
          section = node.next_element
          next unless section

          wrapper = doc.document.create_element('div')
          wrapper['class'] = 'section'
          node.after(wrapper)
          wrapper.add_child(node)
          
          current = section
          while current && current.name != 'h2'
            next_el = current.next
            wrapper.add_child(current)
            current = next_el
          end
        end

        css('p.desc').each { |node| node['class'] = 'section-desc' }
      end

      def format_notes
        css('p').each do |node|
          next unless node.content.start_with?('Note:')
          
          wrapper = doc.document.create_element('div')
          wrapper['class'] = 'admonition note'
          
          title = doc.document.create_element('p')
          title['class'] = 'first admonition-title'
          title.content = 'Note'
          
          content = doc.document.create_element('p')
          content['class'] = 'last'
          content.inner_html = node.inner_html.sub('Note:', '').strip
          
          wrapper.add_child(title)
          wrapper.add_child(content)
          node.replace(wrapper)
        end
      end

      def add_heading_attributes
        css('h1, h2, h3, h4').each do |node|
          node['id'] ||= node.content.strip.downcase.gsub(/[^\w]+/, '-')
          existing_class = node['class'].to_s
          node['class'] = "#{existing_class} section-header"
        end

        format_inline_code
      end

      def format_inline_code
        selectors = ['p', 'li', 'dt', 'dd', '.property-type'].join(', ')
        css(selectors).each do |node|
          next if node.at_css('pre')
          node.inner_html = node.inner_html.gsub(PATTERNS[:inline_code]) do |match|
            "<code class='docutils literal notranslate'><span class='pre'>#{$1}</span></code>"
          end
        end
      end
    end
  end
end 