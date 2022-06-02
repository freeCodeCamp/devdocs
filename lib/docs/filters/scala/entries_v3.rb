# frozen_string_literal: true

module Docs
  class Scala
    class EntriesV3Filter < Docs::EntriesFilter
      REPLACEMENTS = {
        '$eq' => '=',
        '$colon' => ':',
        '$less' => '<',
      }

      def get_name
        if is_package?
          at_css('.cover-header h1').text
        else
          name = slug.split('/').last

          # Some objects have inner objects, show ParentObject$.ChildObject$ instead of ParentObject$$ChildObject$
          name = name.gsub('$$', '$.')

          REPLACEMENTS.each do |key, value|
            name = name.gsub(key, value)
          end

          # If a dollar sign is used as separator between two characters, replace it with a dot
          name.gsub(/([^$.])\$([^$.])/, '\1.\2')
        end
      end

      def get_type
        # if this entry is for a package, we group the package under the parent package
        if is_package?
          parent_package
        # otherwise, group it under the regular package name
        else
          package_name
        end
      end

      def include_default_entry?
        # Ignore package pages
        at_css('.cover-header .micon.pa').nil?
      end

      def additional_entries
        entries = []
        titles = []

        css(".documentableElement").each do |node|
          # Ignore elements without IDs
          id = node['id']
          next if id.nil?

          # Ignore deprecated and inherited members
          next unless node.at_css('.deprecated').nil?

          member_name = node.at_css('.documentableName').content
          title = "#{name}.#{member_name}"
          
          # Add () to methods that take parameters, i.e. methods who have (…)
          # in their signature, ignoring occurrences of (implicit …) and (using …)
          signature = node.at_css('.signature').content
          title += '()' if signature =~ /\((?!implicit)(?!using ).*\)/

          next if titles.include?(title) # Ignore duplicates (function overloading)
        
          entries << [title, id]
          titles.push(title)
        end

        entries
      end

      private

      # For the package name, we use the slug rather than parsing the package
      # name from the HTML because companion object classes may be broken out into
      # their own entries (by the source documentation). When that happens,
      # we want to group these classes (like `scala.reflect.api.Annotations.Annotation`)
      # under the package name, and not the fully-qualfied name which would
      # include the companion object.
      def package_name
        name = package_drop_last(slug_parts)
        name.empty? ? 'scala' : name
      end

      def parent_package
        parent = package_drop_last(package_name.split('.'))
        parent.empty? ? 'scala' : parent
      end

      def package_drop_last(parts)
        parts[0...-1].join('.')
      end

      def slug_parts
        slug.split('/')
      end

      def is_package?
        !at_css('.cover-header .micon.pa').nil?
      end
    end
  end
end
