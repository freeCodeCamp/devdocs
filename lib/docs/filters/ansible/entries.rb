module Docs
  class Ansible
    class EntriesFilter < Docs::EntriesFilter
      TYPES = {
        'intro' => 'Basic Topics',
        'modules' => 'Basic Topics',
        'common' => 'Basic Topics',
        'playbooks' => 'Playbooks',
        'become' => 'Playbooks',
        'test' => 'Playbooks',
        'YAMLSyntax' => 'Playbooks',
        'list' => 'Module Categories',
        'guide' => 'Advanced Topics',
        'developing' => 'Advanced Topics',
        'galaxy' => 'Advanced Topics'
      }

      HIDE_SLUGS = [
        'playbooks',
        'playbooks_special_topics',
        'list_of_all_modules.html',
        'modules_by_category',
        'modules'
      ]

      def get_name
        node = at_css('h1')
        name = node.content.strip
        case
        when name.empty?
          super
        when slug.eql?('modules_intro')
          name = 'Modules'
        when name.eql?('Introduction')
          name = '#Introduction'
        when name.eql?('Getting Started')
          name = '#Getting Started'
        when name.eql?('Introduction To Ad-Hoc Commands')
          name = 'Ad-Hoc Commands'
        end
        name
      end

      def get_type
        if HIDE_SLUGS.include?(slug)
          type = nil
        else
          akey = slug.split('_').first
          type = TYPES.key?(akey) ? TYPES[akey] : 'Modules Reference'
        end
        type
      end

      def additional_entries
        []
      end

      def include_default_entry?
        true
      end
    end
  end
end
