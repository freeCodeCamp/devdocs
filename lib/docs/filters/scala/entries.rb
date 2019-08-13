module Docs
  class Scala
    class EntriesFilter < Docs::EntriesFilter
      REPLACEMENTS = {
        '$eq' => '=',
        '$colon' => ':',
        '$less' => '<',
      }

      def get_name
        if is_package?
          symbol = at_css('#definition h1')
          symbol ? symbol.text.gsub(/\W+/, '') : "package"
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
        true
      end

      def additional_entries
        entries = []

        full_name = "#{type}.#{name}".remove('$')
        css(".members li[name^=\"#{full_name}\"]").each do |node|
          # Ignore packages
          kind = node.at_css('.modifier_kind > .kind')
          next if !kind.nil? && kind.content == 'package'

          # Ignore deprecated members
          next unless node.at_css('.symbol > .name.deprecated').nil?

          id = node['name'].rpartition('#').last
          member_name = node.at_css('.name')

          # Ignore members only existing of hashtags, we can't link to that
          next if member_name.nil? || member_name.content.strip.remove('#').blank?

          member = "#{name}.#{member_name.content}()"
          entries << [member, id]
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
        name.empty? ? '_root_' : name
      end

      def parent_package
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
