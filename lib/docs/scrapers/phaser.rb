module Docs
  class Phaser < UrlScraper
    self.type = 'phaser'
    self.version = '2.3.0'
    self.base_url = "https://phaser.io/docs/#{version}"
    self.links = {
      home: 'https://phaser.io/',
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
      &copy; 2015 Richard Davey, Photon Storm Ltd.<br>
      Licensed under the MIT License.
    HTML
  end
end
