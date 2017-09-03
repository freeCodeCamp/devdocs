# frozen_string_literal: true

module Docs
  class Tensorflow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! 'class '
        name.remove! 'struct '
        name.remove! 'module: '
        name.remove! %r{ \(.+\)}
        name.sub! %r{(?<!\ )\(.+\)}, '()'
        name.remove! %r{\.\z}
        name.sub! 'tf.contrib', 'contrib' unless version == 'Guide'
        name
      end

      TYPE_BY_DIR = {
        'get_started' => 'Get Started',
        'programmers_guide' => 'Guide',
        'tutorials' => 'Tutorials',
        'performance' => 'Performance',
        'deploy' => 'Deploy',
        'extend' => 'Extend'
      }

      def get_type
        return 'Guides' if base_url.path.start_with?('/api_guides')

        if version == 'Guide'
          TYPE_BY_DIR[subpath.split('/').first]
        else
          node = at_css('.devsite-nav-item.devsite-nav-active')
          node = node.ancestors('.devsite-nav-item').first.at_css('.devsite-nav-title')
          type = node.content
          type.remove! %r{\.\z}
          type = 'tf.contrib' if type.start_with?('tf.contrib')
          type
        end
      end
    end
  end
end
