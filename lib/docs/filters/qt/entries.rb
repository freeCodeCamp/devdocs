# frozen_string_literal: true

module Docs
  class Qt
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        header = at_css('h1.title + .small-subtitle a') || at_css('h1.title') || at_css('.context h2')
        name = header.content
        name.sub! %r{ Class$}, ' (class)'
        name.sub! %r{ QML Type$}, ' (QML type)'
        name.sub! %r{ QML Basic Type$}, ' (QML basic type)'

        # Add '(class)' to the class pages where the subtitle name is used (e.g. qset-const-iterator.html)
        if at_css('h1.title').content.strip.end_with?(' Class') && !name.include?('(class)')
          name = "#{name} (class) "
        end

        name
      end

      def get_type
        breadcrumb = css('#main_title_bar + ul li')
        category = if breadcrumb.length < 3
          then 'Qt'.dup
          else breadcrumb.at(1).content
        end

        if category == 'Qt'
          return 'Qt Platforms' if name.include?(' for ') || name == 'Qt Platform Abstraction'
          return 'Qt Quick' if name == 'Qt Quick Test' || name == 'Qt Quick Test Reference Documentation'

          alwaysInQt = ['Qt Configure Options', 'Qt Image Formats']
          category = name if name.start_with?('Qt ') && !alwaysInQt.include?(name)
        end

        qtPlatformsTypes = ['Qt Platform Headers', 'Qt Android Extras', 'Qt Mac Extras', 'Qt Windows Extras', 'Qt X11 Extras']
        return 'Qt Platforms' if qtPlatformsTypes.include?(category)

        category.remove!(' Manual')
        category
      end

      def include_default_entry?
        name != 'All Classes' && name != 'All QML Types'
      end

      def additional_entries
        entries = []
        titles = []

        className = at_css('h1.title').content.strip.remove(' Class')
        displayedClassName = className
        alternativeClassName = at_css('h1.title + .small-subtitle a')
        displayedClassName = alternativeClassName.content if alternativeClassName

        # Functions signatures
        css('h3.fn').each do |node|
          header = node.clone

          # Skip typenames
          next if header.content.strip.start_with?('typename ')

          # Remove leading <a name="">
          header.children.css('a[name]').remove

          # Remove leading <code> tag (virtual/static/… attributes)
          code = header.children.first
          code.remove if code.name == 'code'

          # Remove leading ‘const’
          header.children.first.remove if header.content.strip.start_with?('const ')

          # Remove return type
          returnType = header.children.first
          returnType.remove if returnType['class'] == 'type'

          title = header.content.strip

          # Remove leading '&'/'*'
          title[0] = '' if title[0] == '&' || title[0] == '*'

          # Ignore operator overloads
          next if title.start_with?('operator')

          # Remove function parameters
          title.sub! %r{\(.*\)}, '()'

          # Remove template generics
          title.remove!(%r{^<.*> })

          # Remove ‘const’ at the end
          title.remove!(%r{ const$})

          # Enum/typedef formatting
          title.sub! %r{(enum|typedef) (.*)}, '\2 (\1)'

          # Remove property type
          title = "#{displayedClassName}::#{title}" if title.sub!(%r{ : .*$}, '')

          # Replace the class name by the alternative class name if available
          title = title.sub(className, displayedClassName) if alternativeClassName

          unless titles.include?(title) # Remove duplicates (function overloading)
            entries << [title, header['id']]
            titles.push title
          end
        end

        # QML properties/functions
        qmlTypeName = at_css('h1.title').content.remove(' QML Type', '')
        css('.qmlproto').each do |node|
          title = node.content.strip
          id = node.at_css('tr')['id']

          # Remove options
          title.remove!(%r{^\[.*\] })

          # Remove function parameters
          title.sub! %r{\(.*\)}, '()'

          # Remove property type
          title.remove!(%r{ : .*$})

          # Remove return type
          title.remove!(%r{.* })

          # Remove return type
          title.remove!(%r{.* })

          title = "#{qmlTypeName}.#{title.strip}"
          unless titles.include?(title) # Remove duplicates (function overloading)
            entries << [title, id]
            titles.push(title)
          end
        end

        entries
      end
    end
  end
end
