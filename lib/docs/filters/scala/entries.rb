module Docs
  class Scala
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # this first condition is mainly for scala 212 docs, which
        # have their package listing as index.html
        if is_package?
          symbol = at_css('#definition h1')
          symbol ? symbol.text.gsub(/\W+/, '') : "package"
        else
          slug.split('/').last
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
        true
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
        name.empty? ? '_root_' : name
      end

      def parent_package
        name = package_name
        parent = package_drop_last(package_name.split('.'))
        parent.empty? ? '_root_' : parent
      end

      def package_drop_last(parts)
        parts[0...-1].join('.')
      end

      def slug_parts
        slug.split('/')
      end

      def owner
        at_css('#owner')
      end

      def is_package?
        slug.ends_with?('index') || slug.ends_with?('package')
      end
    end
  end
end
