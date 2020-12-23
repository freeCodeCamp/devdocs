module Docs
  class Gtk
    class EntriesFilter < Docs::EntriesFilter
      # The GTK documentation paths are "flat" and while the contents of each
      # page provides a way to determine the direct parent relationship, we
      # really need a full hierarchy of pages *a priori* to be able to fully
      # categorize all pages and entries. So we're going to recursivly generate
      # a full map of page -> parent relationships from the table of contents...
      PARENT_BY_PATH = {}

      # And then use it to generate the list of 'breadcrumb' paths for each page
      # ex: ['gtkwidgets', 'fancywidgets', 'gtkexamplewidget']
      attr_accessor :breadcrumbs

      # Map of paths to Page Names/Titles
      NAME_BY_PATH = {}

      # GTK+ 3 and GTK 4
      REPLACE_NAMES = {
        'I. GTK+ Overview' => '1. Overview',
        'II. GTK+ Widgets and Objects' => '2. Widgets and Objects',
        'III. GTK+ Core Reference' => '3. Core Reference',
        'IV. Theming in GTK+' => '4. Theming',
        'VI. GTK+ Tools' => '6. Tools',
        'VII. GTK+ Platform Support' => '7. Platform Support',

        'I. Introduction' => '1. Introduction',
        'II. GTK Concepts' => '2. Concepts',
        'III. GTK Widgets and Objects' => '3. Widgets and Objects',
        'IV. GTK Core Reference' => '4. Core Reference',
        'V. Theming in GTK' => '5. Theming',
        'VII. GTK Tools' => '7. Tools',
        'VIII. GTK Platform Support' => '8. Platform Support'
      }

      def call
        if root_page?
          # Generate NAME_BY_PATH Hash
          css('dl.toc a').each do |node|
            name = node.content
            path = node['href'].split('/').last.remove('.html')
            NAME_BY_PATH[path] = REPLACE_NAMES[name] || name
          end
          # Generate PARENT_BY_PATH Hash
          process_toc(at_css('dl.toc'), nil)
        end
        super
      end

      # Recursive depth-first search
      # Treat solo 'dt' nodes as leaf nodes and
      # sibling 'dt + dd' nodes as nodes with children
      def process_toc(toc_dl_node, parent_path)
        toc_dl_node.css('> dt').each do |node|
          node_path = node.at_css('a')['href'].split('/').last.remove('.html')
          PARENT_BY_PATH[node_path] = parent_path

          if node.next_element && node.next_element.name == 'dd'
            children = node.next_element.children.first
            process_toc(children, node_path)
          end
        end
      end

      def breadcrumbs
        @breadcrumbs ||= get_breadcrumbs
      end

      def get_breadcrumbs
        return [] if root_page?

        breadcrumbs = []
        path = slug.downcase
        while path
          breadcrumbs.prepend path
          path = PARENT_BY_PATH[path]
        end

        breadcrumbs
      end

      def get_name
        NAME_BY_PATH[self.breadcrumbs.last]
      end

      def get_type
        NAME_BY_PATH[self.breadcrumbs.first]
      end

      def additional_entries
        entries = []
        type = case self.breadcrumbs.first
        when 'gtkobjects'
          "Widgets / #{NAME_BY_PATH[self.breadcrumbs[1]]}"
        when 'gtkbase'
          "Base / #{self.name}"
        when'theming'
          "Theming / #{self.name}"
        end

        if funcs = at_css('h2:contains("Functions")')
          funcs.next_element.css('td.function_name > a').each do |node|
            name = "#{node.content}()"
            id = node['href']
            entries << [name, id, type]
          end
        end

        css('td.property_name > a').each do |node|
          name = "#{node.content} (#{self.name} property)"
          id = node['href']
          entries << [name, id, type]
        end

        css('td.signal_name > a').each do |node|
          name = "#{node.content} (#{self.name} signal)"
          id = node['href']
          entries << [name, id, type]
        end

        css('td.enum_member_name').each do |node|
          name = node.content
          id = node.at_css('a')['name']
          entries << [name, id, type]
        end

        if values_node = at_css('h2:contains("Types and Values") + .informaltable')
          values_node.css('tr').each do |node|
            data_type = node.css('td').first.content
            name = node.at_css('td.function_name').content
            if data_type == ' '
              name = "#{name} (type)"
            elsif data_type == 'enum' || data_type == 'struct'
              name = "#{name} (#{data_type})"
            end
            id = node.at_css('td.function_name a')['href']
            entries << [name, id, type]
          end
        end

        if slug == 'gtk-running'
          css('h3 > a[name]').each do |node|
            name = node.parent.content
            id = node['name']
            entries << [name, id, 'Platform / Environment Variables']
          end
        end

        entries
      end

    end
  end
end
