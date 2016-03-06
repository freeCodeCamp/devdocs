module Docs
  class Ansible
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00B6}"
        name.remove! %r{ \- .*}
        name.remove! 'Introduction To '
        name.remove! %r{ Guide\z}
        name
      end

      def get_type
        if slug.include?('module')
          if name =~ /\A[a-z]/ && node = css('.toctree-l2.current').last
            "Modules: #{node.content.remove(' Modules')}"
          else
            'Modules'
          end
        elsif slug.include?('playbook')
          'Playbooks'
        elsif slug.include?('guide')
          'Guides'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
