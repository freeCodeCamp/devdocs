module Docs
  class Love < UrlScraper
    self.name = 'LÖVE'
    self.slug = 'love'
    self.type = 'love'
    self.release = '0.10.2'
    self.base_url = 'https://love2d.org/wiki/'
    self.root_path = 'Main_Page'
    self.initial_paths = %w(love love.audio love.event love.filesystem love.font love.graphics
      love.image love.joystick love.keyboard love.math love.mouse love.physics love.sound
      love.system love.thread love.timer love.touch love.video love.window enet socket utf8)
    self.links = {
      home: 'https://love2d.org/',
      code: 'https://bitbucket.org/rude/love'
    }

    html_filters.push 'love/entries', 'love/clean_html', 'title'

    options[:root_title] = 'LÖVE'
    options[:decode_and_clean_paths] = true
    options[:container] = '#bodyContent'

    options[:skip] = %w(Getting_Started Building_LÖVE Tutorial Tutorials Game_Distribution License
      Games Libraries Software Snippets Version_History Lovers PO2_Syndrome HSL_color Guidelines)

    options[:skip_patterns] = [
      /_\([^\)]+\)\z/, # anything_(language)
      /\A(Special|Category|File|Help|Template|User|Tutorial):/,
      /\A\d/
    ]

    options[:replace_paths] = {
      'Config_Files' => 'love.conf',
      'conf.lua' => 'love.conf',
      'lua-enet' => 'enet'
    }

    options[:attribution] = <<-HTML
      &copy; 2006&ndash;2016 L&Ouml;VE Development Team<br>
      Licensed under the GNU Free Documentation License, Version 1.3.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://love2d.org/wiki/Version_History', opts)
      doc.at_css('#mw-content-text table a').content
    end
  end
end
