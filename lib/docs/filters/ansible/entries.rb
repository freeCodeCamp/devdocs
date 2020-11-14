module Docs
  class Ansible
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00B6}"
        name.remove! %r{ \- .*}
        name.remove! 'Introduction To '
        name.remove! %r{ Guide\z}

        if version == "2.10"
          if slug =~ /\Acollections\// and slug !~ /index$/
            name = name.split('.')[2]
          end
        end

        name
      end

      def get_type
        if version == '2.4'
          if slug.include?('module')
            if name =~ /\A[a-z]/ && node = css('.toctree-l2.current').last
              return "Modules: #{node.content.remove(' Modules')}"
            else
              return 'Modules'
            end
          end
        end

        if version == "2.10"
          if slug =~ /\Acollections\//
            return "Collection #{slug.split('/')[1..-2].join(".")}"
          end
        end

        if slug =~ /\Acli\//
          'CLI Reference'
        elsif slug =~ /\Anetwork\//
          'Network'
        elsif slug =~ /\Aplugins\//
          if name =~ /\A[a-z]/ && node = css('.toctree-l3.current').last
            "Plugins: #{node.content.sub(/ Plugins.*/, '')}"
          else
            'Plugins'
          end
        elsif slug =~ /\Amodules\//
          if slug =~ /\Amodules\/list_/ || slug=~ /_maintained\z/
            'Modules: Categories'
          else
            'Modules'
          end
        elsif slug.include?('playbook')
          'Playbooks'
        elsif slug =~ /\Auser_guide\//
          'Guides: User'
        elsif slug =~ /\Ascenario_guides\//
          'Guides: Scenarios'
        elsif slug.include?('guide')
          'Guides'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
