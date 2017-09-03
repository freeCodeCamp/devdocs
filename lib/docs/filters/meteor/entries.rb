module Docs
  class Meteor
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('.item-toc.current').content
      end

      def get_type
        if subpath.start_with?('api')
          name
        else
          return 'Guide: Blaze' if base_url.host == 'blazejs.org' && subpath.start_with?('guide')
          type = at_css('.item-toc.current').ancestors('li').first.at_css('.heading-toc').try(:content) || 'Guide'
          type.prepend 'Guide: ' if base_url.host == 'guide.meteor.com' && type != 'Guide'
          type
        end
      end

      def additional_entries
        if slug == 'commandline'
          css('h2[id]').map do |node|
            [node.content, node['id']]
          end
        else
          css('.title-api[id]').map do |node|
            name = node.content.strip
            name.sub! %r{\(.+\)}, '()'
            name.remove! 'new '
            name = '{{> Template.dynamic }}' if name.include?('Template.dynamic')
            [name, node['id']]
          end
        end
      end
    end
  end
end
