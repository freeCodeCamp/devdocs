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
        name.remove! %r{\A\w+: }
        name.remove! 'Phaser.'
        name.remove! 'PIXI.'
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

      def additional_entries
        return [] if self.name == 'KeyCode'
        entries = []

        %w(members methods).each do |type|
          css("##{type} h4.name").each do |node|
            sig = node.at_css('.type-signature')
            next if node.parent.parent.at_css('.inherited-from') || (sig && sig.content.include?('internal'))
            sep = sig && sig.content.include?('static') ? '.' : '#'
            function = node['id'].remove(/\A\./)
            name = "#{self.name}#{sep}#{function}#{'()' if type == 'methods'}"
            entries << [name, node['id']]
          end
        end

        entries
      end
    end
  end
end
