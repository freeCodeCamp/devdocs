module Docs
  class Phaser
    class EntriesFilter < Docs::EntriesFilter

      REPLACE_TYPES = {
        'gameobjects' => 'Game Objects',
        'geom'        => 'Geometry',
        'tilemap'     => 'Tilemaps',
        'net'         => 'Network',
        'tween'       => 'Tweens',
        'pixi'        => 'PIXI'
      }

      TYPE_GROUPS = {
        'Core' => ['loader']
      }

      def get_name
        name = at_css('.title-frame h1').content
        name.sub! /Phaser\./, ''
        name.sub! /PIXI\./, ''
        name
      end

      def get_type
        src = at_css('.container-overview .details > .tag-source > a')

        if src
          src = src.content.split('/').first

          TYPE_GROUPS.each_pair do |replacement, types|
            types.each do |t|
              return replacement if src == t
            end
          end

          return REPLACE_TYPES[src] || src.capitalize
        end

        'Global'
      end
    end
  end
end
