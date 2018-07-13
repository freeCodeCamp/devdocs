module Docs
  class Dart
    class CleanHtmlFilter < Filter
      def call
        # Move the title into the main content node in the v1 docs
        title = at_css('h1.title')
        unless title.nil?
          name = title.children.last.content.strip
          kind = title.at_css('.kind').content
          at_css('.main-content').prepend_child("<h1>#{name} #{kind}</h1>")
        end

        # Extract the actual content
        # We can't use options[:container] here because the entries filter uses the breadcrumbs node
        @doc = at_css('.main-content')

        # Move the features (i.e. "read-only, inherited") into the blue header
        css('.features').each do |node|
          header = node.xpath('parent::dd/preceding::dt').last
          header.add_child node unless header.nil?
        end

        # Make code blocks detectable by Prism
        css('pre').each do |node|
          node['data-language'] = 'dart'
        end

        doc
      end
    end
  end
end
