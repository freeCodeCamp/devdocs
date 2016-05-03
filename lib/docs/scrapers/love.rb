module Docs
  class Love < UrlScraper
    LOVE_MODULES = %w(
      love
      love.audio
      love.event
      love.filesystem
      love.font
      love.graphics
      love.image
      love.joystick
      love.keyboard
      love.math
      love.mouse
      love.physics
      love.sound
      love.system
      love.thread
      love.timer
      love.touch
      love.video
      love.window
    )
    TYPE_OVERRIDE = {
      "Audio_Formats" => "love.sound",
      "ImageFontFormat" => "love.font",
      "BlendMode_Formulas" => "BlendMode",
      "Shader_Variables" => "Shader"
    }

    self.name = 'LÖVE'
    self.slug = 'love'
    self.type = 'love'
    self.base_url = 'https://love2d.org/wiki/'
    self.root_path = 'love'
    self.initial_paths = LOVE_MODULES
    self.links = {
      home: 'https://love2d.org/',
      code: 'https://bitbucket.org/rude/love'
    }

    html_filters.push 'love/clean_html', 'love/entries', 'title'

    options[:root_title] = 'love'
    options[:initial_paths] = LOVE_MODULES

    options[:decode_and_clean_paths] = true

    # Add types to classes and their members
    options[:list_classes] = true

    options[:container] = '#mw-content-text'

    options[:only_patterns] = [
      /\A(love\z|love\.|[A-Z]|\([A-Z])/
      # love
      # love.* (modules and functions)
      # Uppercased (classes and enums)
      # (Uppercased) (generalized classes)
    ]
    options[:skip] = %w(
      Getting_Started
      Building_LÖVE
      Tutorial
      Tutorials
      Game_Distribution
      License
      Games
      Libraries
      Software
      Snippets
      Version_History
      Lovers
      PO2_Syndrome
      HSL_color
    )
    options[:skip_patterns] = [
      /_\([^\)]+\)\z/,
      # anything_(language) (this might have to be tweaked)
      /\ASpecial:/,
      /\ACategory:/,
      /\AFile:/,
      /\AHelp:/,
      /\ATemplate:/,
      /\AUser:/,
      /\ATutorial:/
      # special pages are indistinguishable from instance methods
    ]

    options[:replace_paths] = {
      "Config_Files" => "love.conf"
    }

    options[:attribution] = <<-HTML
      &copy; L&Ouml;VE Development Team<br>
      Licensed under the GNU Free Documentation License, Version 1.3.
    HTML
  end
end
