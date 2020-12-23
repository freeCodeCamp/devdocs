module Docs
  class Gtk < UrlScraper
    self.name = 'GTK'
    self.slug = 'gtk'
    self.type = 'gtk'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.gtk.org/',
      code: 'https://gitlab.gnome.org/GNOME/gtk/'
    }

    html_filters.push 'gtk/entries', 'gtk/clean_html', 'title'

    options[:container] = '.content'

    # These are all "index"-ish pages with no valuable content
    GTK3_SKIP = %w(
      gtk.html
        gtk-resources.html gtk-question-index.html
      gtkobjects.html
        Application.html Builder.html WindowWidgets.html LayoutContainers.html
        DisplayWidgets.html ButtonWidgets.html NumericEntry.html
        TextWidgetObjects.html TreeWidgetObjects.html MenusAndCombos.html
        SelectorWidgets.html Ornaments.html ScrollingWidgets.html Printing.html
        ShortcutsOverview.html MiscObjects.html AbstractObjects.html
        PlugSocket.html RecentDocuments.html ApplicationChoosing.html
        Gestures.html DeprecatedObjects.html
      gtkbase.html
      theming.html
      migrating.html
        ch26s02.html ch28s02.html
      pt06.html
      platform-support.html
      glossary.html
      annotation-glossary.html
    )

    GTK3_SKIP_PATTERNS = [
      /migrating/, /checklist/, /ch30/, /ch32/, /api-index-/
    ]

    # These are all "index"-ish pages with no valuable content
    GTK4_SKIP = %w(
      gtk.html
        gtk-resources.html gtk-question-index.html ch02s02.html
      concepts.html
      gtkobjects.html
        Lists.html Trees.html Application.html Builder.html WindowWidgets.html
        LayoutContainers.html LayoutManagers.html DisplayWidgets.html
        MediaSupport.html ButtonWidgets.html NumericEntry.html
        MenusAndCombos.html SelectorWidgets.html DrawingWidgets.html
        Ornaments.html ScrollingWidgets.html Printing.html
        ShortcutsOverview.html MiscObjects.html AbstractObjects.html
        RecentDocuments.html ApplicationChoosing.html Gestures.html ch36.html
        ch37.html
      gtkbase.html
      theming.html
      migrating.html
        ch41s02.html ch41s03.html
      pt07.html
      platform-support.html
      api-index-full.html
      annotation-glossary.html
    )

    GTK4_SKIP_PATTERNS = [
      /migrating/, /ch03/, /ch09/, /ch10/
    ]

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2020 The GNOME Project<br>
      Licensed under the GNU Lesser General Public License version 2.1 or later.
    HTML

    version '4.0' do
      self.release = '4.0.0'
      self.base_url = "https://developer.gnome.org/gtk4/#{self.version}/"

      options[:root_title] = 'GTK 4 Reference Manual'
      options[:skip] = GTK4_SKIP
      options[:skip_patterns] = GTK4_SKIP_PATTERNS
    end

    version '3.24' do
      self.release = '3.24.24'
      self.base_url = "https://developer.gnome.org/gtk3/#{self.version}/"

      options[:root_title] = 'GTK+ 3 Reference Manual'
      options[:skip] = GTK3_SKIP
      options[:skip_patterns] = GTK3_SKIP_PATTERNS
    end

    version '3.22' do
      self.release = '3.22.3'
      self.base_url = "https://developer.gnome.org/gtk3/#{self.version}/"

      options[:root_title] = 'GTK+ 3 Reference Manual'
      options[:skip] = GTK3_SKIP
      options[:skip_patterns] = GTK3_SKIP_PATTERNS
    end

    version '3.20' do
      self.release = '3.20.4'
      self.base_url = "https://developer.gnome.org/gtk3/#{self.version}/"

      options[:root_title] = 'GTK+ 3 Reference Manual'
      options[:skip] = GTK3_SKIP
      options[:skip_patterns] = GTK3_SKIP_PATTERNS
    end

    def get_latest_version(opts)
      tags = get_gitlab_tags('gitlab.gnome.org', 'GNOME', 'gtk', opts)
      tags[0]['name']
    end
  end
end
