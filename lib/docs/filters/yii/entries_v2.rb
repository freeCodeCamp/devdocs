module Docs
  class Yii
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! %r{\A.*?(Class|Trait|Interface)\s*}
        name.remove!('yii\\')
        name
      end

      def get_type
        if slug.include?('guide')
          'Guides'
        else
          components = name.split('\\')
          type = components.first
          type << "\\#{components.second}" if (type == 'db' && components.second.in?(%w(cubrid mssql mysql oci pgsql sqlite))) ||
                                              (type == 'web' && components.second.in?(%w(Request Response)))
          type = 'yii' if type == 'BaseYii' || type == 'Yii'
          type
        end
      end

      def additional_entries
        css('.detail-header').each_with_object [] do |node, entries|
          name = node.child.content.strip
          name.prepend "#{self.name} "
          entries << [name, node['id']]
          node.remove_attribute('class')
        end
      end
    end
  end
end
