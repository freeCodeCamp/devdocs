module Docs
  class Phaser < UrlScraper
    self.type = 'phaser'
    self.release = '2.6.2'
    self.base_url = "http://phaser.io/docs/#{release}"
    self.root_path = '/index'
    self.links = {
      home: 'http://phaser.io/',
      code: 'https://github.com/photonstorm/phaser'
    }

    html_filters.push 'phaser/entries', 'phaser/clean_html'

    options[:skip] = %w(
      /docs_pixi-jsdoc.js.html
      /p2.Body.html
      /Phaser.html
      /PIXI.html
      /PIXI.WebGLMaskManager.html
      /PIXI.WebGLShaderManager.html
      /PIXI.WebGLSpriteBatch.html
      /PIXI.WebGLStencilManager.html)

    options[:attribution] = <<-HTML
      &copy; 2016 Richard Davey, Photon Storm Ltd.<br>
      Licensed under the MIT License.
    HTML
  end
end
