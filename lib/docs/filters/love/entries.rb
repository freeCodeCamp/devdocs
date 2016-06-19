module Docs
  class Love
    class EntriesFilter < Docs::EntriesFilter
      TYPES = {
        'require'                 => 'Lua',
        'light_userdata'          => 'Lua',
        'value'                   => 'Lua',
        'variable'                => 'Lua',

        'Audio_Formats'           => 'love.sound',
        'ImageFontFormat'         => 'love.font',
        'BlendMode_Formulas'      => 'love.graphics',
        'Shader_Variables'        => 'love.graphics',

        'AreaSpreadDistribution'  => 'love.graphics',
        'BodyType'                => 'love.physics',
        'BufferMode'              => 'love.filesystem',
        'CompressedFormat'        => 'love.image',
        'JoystickConstant'        => 'love.joystick',
        'ParticleInsertMode'      => 'love.graphics',
        'String'                  => 'love',
        'TextureMode'             => 'love.graphics'
      }

      def call
        if context[:initial_paths].include?(slug)
          css('table.smwtable td:first-child > a').each do |node|
            TYPES[node.content.strip] = slug
          end
        end

        super
      end

      def get_type
        if slug == 'love'
          'love'
        elsif slug.start_with?('enet')
          'enet'
        elsif slug.include?('Joint') || slug.include?('Shape')
          'love.physics'
        elsif TYPES.key?(slug)
          TYPES[slug]
        elsif match = slug.match(/\A(love\.\w+)(\.\w+)?\z/)
          match[2] || context[:initial_paths].include?(match[1]) ? match[1] : 'love'
        elsif at_css('#catlinks a[title="Category:Lua"]')
          'Lua'
        elsif
          type = slug.split(':').first
          type.remove! %r{[\(\)]}
          TYPES[type]
        end
      end
    end
  end
end
