module Docs
  class Qt < UrlScraper
    self.name = 'Qt'
    self.type = 'qt'
    self.initial_paths = %w(classes.html qmltypes.html)
    self.root_path = 'index.html'
    self.links = {
      home: 'https://www.qt.io',
      code: 'https://code.qt.io/cgit/'
    }

    html_filters.push 'qt/entries', 'qt/clean_html'

    options[:container] = '.main'
    options[:max_image_size] = 156_000
    options[:skip_patterns] = [
      # License, copyright attributions
      /3rdparty/,
      /attribution/,
      /license/,
      /licensing/,

      # Examples, guides, tutorials
      /example/,
      /guide$/,
      /tutorial/,
      /porting/,
      /usecase/,
      /topic/,
      /^modelview/,
      /deploy(ing|ment)/,
      /building/,

      # Old versions, changelog
      /obsolete/,
      /compatibility/,
      /^whatsnew/,
      /^newclasses/,

      # Deprecated modules
      /(qtopengl|qgl)/,
      /qt?script/,

      # Indexes
      /members/,
      /module/,
      /overview/,
      /^qopenglfunctions/,

      # Tooling
      /^(qt)?(linguist|assistant|qdbusviewer)/,
    ]

    options[:skip] = [
      "qt5-intro.html",
      "compatmap.html",

      # Indexes
      "classes.html",
      "qtmodules.html",
      "modules-qml.html",
      "modules-cpp.html",
      "functions.html",
      "namespaces.html",
      "qmltypes.html",
      "qt3d-qml.html",
      "qmlbasictypes.html",
      "guibooks.html",
      "annotated.html",
      "overviews-main.html",
      "reference-overview.html",

      # Tutorials
      "qtvirtualkeyboard-build.html",

      # Copyright
      "trademarks.html",
      "lgpl.html",
      "bughowto.html",

      # Changelogs
      "changes.html",
      "qtlocation-changes.html",
      "sourcebreaks.html",

      # Best practice guides
      "accessible.html",
      "accessible-qtquick.html",
      "sharedlibrary.html",
      "exceptionsafety.html",
      "scalability.html",
      "session.html",
      "appicon.html",
      "accelerators.html",

      # Other
      "ecmascript.html",
      "qtremoteobjects-interaction.html",
    ]

    options[:attribution] = <<-HTML
      &copy; The Qt Company Ltd<br>
      Licensed under the GNU Free Documentation License, Version 1.3.
    HTML

    version '5.11' do
      self.release = '5.11'
      self.base_url = 'https://doc.qt.io/qt-5/'
    end

    version '5.9' do
      self.release = '5.9'
      self.base_url = 'https://doc.qt.io/qt-5.9/'
    end

    version '5.6' do
      self.release = '5.6'
      self.base_url = 'https://doc.qt.io/qt-5.6/'
    end
  end
end
