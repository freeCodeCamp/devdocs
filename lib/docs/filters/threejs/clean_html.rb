module Docs
  class Threejs
    class CleanHtmlFilter < Filter
      def call
        # Remove unnecessary elements
        css('head, script, style').remove
        
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
        
        # Clean up code blocks
        css('pre').each do |node|
          wrapper = doc.document.create_element('div')
          wrapper['class'] = 'highlight'
          node.replace(wrapper)
          
          div = doc.document.create_element('div')
          div['class'] = 'highlight-javascript notranslate'
          wrapper.add_child(div)
          
          pre = doc.document.create_element('pre')
          pre['class'] = ''
          div.add_child(pre)

          # Format the code content
          code = node.content.strip
          
          # Add syntax highlighting spans
          highlighted_code = highlight_javascript(code)
          
          pre.inner_html = highlighted_code
        end

        # Add proper heading IDs and classes
        css('h1, h2, h3, h4').each do |node|
          node['id'] ||= node.content.strip.downcase.gsub(/[^\w]+/, '-')
          existing_class = node['class'].to_s
          node['class'] = "#{existing_class} section-header"
        end

        # Remove interactive examples
        css('.threejs_example_container').remove

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

        # Remove the navigation arrows and links
        css('.nav').remove if at_css('.nav')
        # If the arrows are in a different container, adjust the selector accordingly
        
        doc
      end

      private

      def highlight_javascript(code)
        code = code.gsub(/\b(function|return|var|let|const|if|else|for|while|do|switch|case|break|continue|new|try|catch|throw|this|typeof|instanceof|in|of|class|extends|super|import|export|default|null|undefined|true|false)\b/, '<span class="k">\1</span>') # keywords
        code = code.gsub(/\b(\d+(\.\d+)?)\b/, '<span class="mi">\1</span>') # numbers
        code = code.gsub(/'([^']*)'/, '<span class="s1">\'\1\'</span>') # single quotes
        code = code.gsub(/"([^"]*)"/, '<span class="s2">"\1"</span>') # double quotes
        code = code.gsub(/`([^`]*)`/, '<span class="s2">`\1`</span>') # template literals
        code = code.gsub(/\/\/[^\n]*/, '<span class="c1">\0</span>') # single line comments
        code = code.gsub(/\b(console|document|window|Array|Object|String|Number|Boolean|Function|Symbol|Map|Set|Promise|async|await)\b/, '<span class="nb">\1</span>') # built-ins
        code = code.gsub(/([a-zA-Z_$][a-zA-Z0-9_$]*)\s*\(/, '<span class="nx">\1</span>(') # function calls
        code = code.gsub(/\b(addEventListener|querySelector|getElementById|setTimeout|setInterval)\b/, '<span class="nx">\1</span>') # common methods
        
        # Add line numbers
        lines = code.split("\n")
        numbered_lines = lines.map.with_index(1) do |line, i|
          "<span class=\"lineno\">#{i}</span>#{line}"
        end
        
        numbered_lines.join("\n")
      end
    end
  end
end 