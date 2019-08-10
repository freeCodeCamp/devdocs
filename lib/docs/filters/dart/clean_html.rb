module Docs
  class Dart
    class CleanHtmlFilter < Filter
      def call
        # Move the title into the main content node in the v1 docs
        title = at_css('h1.title')
        if title
          name = title.children.last.content.strip
          kind = title.at_css('.kind').content
          at_css('.main-content').prepend_child("<h1>#{name} #{kind}</h1>")
        end

        # Add a title to the homepage of the v2 docs
        if subpath == 'index.html' && at_css('.main-content > h1').nil?
          at_css('.main-content').prepend_child('<h1>Dart SDK</h1>')
        end

        # Add the library to the main content (it is not always visible in the menu entry)
        breadcrumbs = at_css('.breadcrumbs').css('li:not(.self-crumb) > a')
        if breadcrumbs.length > 1
          library = breadcrumbs[1].content

          # Generate the link to the homepage of the library
          with_hypens = library.gsub(/:/, '-')
          location = "#{'../' * subpath.count('/')}#{with_hypens}/#{with_hypens}-library"
          link = "<a href=\"#{location}\" class=\"_links-link\">#{library}</span>"

          # Add the link to the main title, just like how the "Homepage" and "Source code" links appear
          at_css('.main-content').prepend_child("<p class=\"_links\">#{link}</p>")
        end

        # Extract the actual content
        # We can't use options[:container] here because the entries filter uses the breadcrumbs node
        @doc = at_css('.main-content')

        # Move the features (i.e. "read-only, inherited") into the blue header
        css('.features').each do |node|
          header = node.xpath('parent::dd/preceding::dt').last
          header.add_child node unless header.nil?
        end

        css('section').each do |node|
          if node['id'] && node.first_element_child
            node.first_element_child['id'] ||= node['id']
          end

          node.before(node.children).remove
        end

        css('span').each do |node|
          node.before(node.children).remove
        end

        # Make code blocks detectable by Prism
        css('pre').each do |node|
          node['data-language'] = 'dart'
          node.content = node.content
        end

        css('.properties', '.property', '.callables', '.callable').remove_attr('class')

        doc
      end
    end
  end
end
