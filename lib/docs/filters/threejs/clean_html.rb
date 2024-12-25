module Docs
  class Threejs
    class CleanHtmlFilter < Filter
      def call
        # Remove unnecessary elements
        css('head, script, style').remove
        # Wrap code blocks with pre tags and add syntax highlighting
        css('code').each do |node|
          unless node.parent.name == 'pre'
            pre = node.wrap('<pre>')
            pre['data-language'] = 'javascript'
            pre['class'] = 'language-javascript'
          end
        end
        
        # Handle source links
        css('h2').each do |node|
          if node.content.strip == 'Source'
            content = node.next_element&.inner_html
            if content
              # Clean up any existing formatting
              content = content.gsub(/<[^>]+>/, '')
              # Extract the path from the content
              if content =~ /src\/(.*?)\.js/
                path = "/#{$1}.js"
                formatted_link = %Q(<a class="reference external" href="https://github.com/mrdoob/three.js/blob/master/src#{path}">src#{path}</a>)
                node.next_element.inner_html = formatted_link if node.next_element
              end
            end
          end
        end

        # Handle method signatures
        css('h3').each do |node|
          content = node.inner_html

          # Handle [method:this methodName]( param1, param2, ... ) format
          content = content.gsub(/\[method:this\s+([^\]]+)\]\s*\((.*?)\)/) do |match|
            method_name, params_str = $1, $2
            
            # Format parameters
            params = params_str.split(',').map do |param|
              param = param.strip
              if param.include?(' ')
                type, name = param.split(' ', 2).map(&:strip)
                "<span class='sig-param'><span class='sig-type'>#{type}</span> <span class='sig-name'>#{name}</span></span>"
              else
                "<span class='sig-param'>#{param}</span>"
              end
            end.join("<span class='sig-paren'>, </span>")

            "<dt class='sig sig-object js' id='#{method_name}'>" \
            "<span class='property'><span class='pre'>this</span></span>." \
            "<span class='sig-name descname'>#{method_name}</span>" \
            "<span class='sig-paren'>(</span>" \
            "#{params}" \
            "<span class='sig-paren'>)</span></dt>"
          end

          # Handle [method:returnType methodName]( param1, param2, ... ) format
          content = content.gsub(/\[method:([^\s\]]+)\s+([^\]]+)\]\s*\((.*?)\)/) do |match|
            return_type, method_name, params_str = $1, $2, $3
            next if method_name.start_with?('this') # Skip if already handled above
            
            # Format parameters
            params = params_str.split(',').map do |param|
              param = param.strip
              if param.include?(' ')
                type, name = param.split(' ', 2).map(&:strip)
                "<span class='sig-param'><span class='sig-type'>#{type}</span> <span class='sig-name'>#{name}</span></span>"
              else
                "<span class='sig-param'>#{param}</span>"
              end
            end.join("<span class='sig-paren'>, </span>")

            "<dt class='sig sig-object js' id='#{method_name}'>" \
            "<span class='sig-name descname'>#{method_name}</span>" \
            "<span class='sig-paren'>(</span>" \
            "#{params}" \
            "<span class='sig-paren'>)</span>" \
            "<span class='sig-returns'><span class='sig-colon'>:</span> " \
            "<span class='sig-type'>#{return_type}</span></span></dt>"
          end

          # Handle [method:returnType methodName] format (no parameters)
          content = content.gsub(/\[method:([^\s\]]+)\s+([^\]]+)\](?!\()/) do |match|
            return_type, method_name = $1, $2
            "<dt class='sig sig-object js' id='#{method_name}'>" \
            "<span class='sig-name descname'>#{method_name}</span>" \
            "<span class='sig-paren'>(</span>" \
            "<span class='sig-paren'>)</span>" \
            "<span class='sig-returns'><span class='sig-colon'>:</span> " \
            "<span class='sig-type'>#{return_type}</span></span></dt>"
          end

          node.inner_html = content
        end

        # Handle [name] placeholders in headers and constructor
        css('h1, h3').each do |node|
          content = node.inner_html
          
          # Replace [name] with class name
          content = content.gsub(/\[name\]/) do
            name = slug.split('/').last.gsub('.html', '')
            "<span class='descname'>#{name}</span>"
          end
          
          # Format constructor parameters
          content = content.gsub(/\[param:([^\]]+?)\s+([^\]]+?)\]/) do |match|
            type, name = $1, $2
            "<span class='sig-param'><span class='sig-type'>#{type}</span> <code class='sig-name'>#{name}</code></span>"
          end
          
          node.inner_html = content
        end

        # Clean up property formatting
        css('h3').each do |node|
          node.inner_html = node.inner_html.gsub(/\[property:([^\]]+?)\s+([^\]]+?)\]/) do |match|
            type, name = $1, $2
            "<dt class='sig sig-object js'>" \
            "<span class='sig-name descname'>#{name}</span>" \
            "<span class='sig-colon'>:</span> " \
            "<span class='sig-type'>#{type}</span></dt>"
          end
        end

        # Clean up external links
        css('*').each do |node|
          next if node.text?
          
          # Handle example links [example:tag Title]
          node.inner_html = node.inner_html.gsub(/\[example:([^\s\]]+)\s+([^\]]+)\]/) do |match|
            tag, title = $1, $2
            "<a class='reference external' href='https://threejs.org/examples/##{tag}'>#{title}</a>"
          end

          # Handle external links with [link:url text] format
          node.inner_html = node.inner_html.gsub(/\[link:([^\s\]]+)\s+([^\]]+)\]/) do |match|
            url, text = $1, $2
            "<a class='reference external' href='#{url}'>#{text}</a>"
          end

          # Handle external links with [link:url] format
          node.inner_html = node.inner_html.gsub(/\[link:([^\]]+)\]/) do |match|
            url = $1
            "<a class='reference external' href='#{url}'>#{url}</a>"
          end

          # Handle internal page links with text
          node.inner_html = node.inner_html.gsub(/\[page:([^\]]+?)\s+([^\]]+?)\]/) do
            path, text = $1, $2
            "<a class='reference internal' href='#{path.downcase}'><code class='xref js js-#{path.downcase}'>#{text}</code></a>"
          end

          # Handle internal page links without text
          node.inner_html = node.inner_html.gsub(/\[page:([^\]]+?)\]/) do |match|
            path = $1
            "<a class='reference internal' href='#{path.downcase}'><code class='xref js js-#{path.downcase}'>#{path}</code></a>"
          end
        end

        # Fix all href attributes to be lowercase and remove .html
        css('a[href]').each do |link|
          next if link['href'].start_with?('http')
          link['href'] = link['href'].remove('../').downcase.sub(/\.html$/, '')
          link['class'] = 'reference internal'
        end

        # Add section classes
        css('h2').each do |node|
          node['class'] = 'section-title'
          section = node.next_element
          if section
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
        end

        # Format description paragraphs
        css('p.desc').each do |node|
          node['class'] = 'section-desc'
        end

        # Handle inline code/backticks in text
        css('p, li, dt, dd').each do |node|
          next if node.at_css('pre') # Skip if contains a code block
          
          # Replace backticks with proper code formatting
          node.inner_html = node.inner_html.gsub(/`([^`]+)`/) do |match|
            code = $1
            "<code class='docutils literal notranslate'><span class='pre'>#{code}</span></code>"
          end
        end

        # Handle inline code in property descriptions
        css('.property-type').each do |node|
          node.inner_html = node.inner_html.gsub(/`([^`]+)`/) do |match|
            code = $1
            "<code class='docutils literal notranslate'><span class='pre'>#{code}</span></code>"
          end
        end
        
        # Add proper heading IDs and classes
        css('h1, h2, h3, h4').each do |node|
          node['id'] ||= node.content.strip.downcase.gsub(/[^\w]+/, '-')
          existing_class = node['class'].to_s
          node['class'] = "#{existing_class} section-header"
        end

        # Add note styling
        css('p').each do |node|
          if node.content.start_with?('Note:')
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
        doc
      end
    end
  end
end 