module Docs
  class Chefclient
    class EntriesFilter < Docs::EntriesFilter

      ADDITIONAL_URLS = [
        {
          slug: 'knife_common_options',
          type: 'Miscellaneous/Knife',
          name: 'Common options'
        },
        {
          slug: 'knife_using',
          type: 'Miscellaneous/Knife',
          name: 'Using knife'
        },
        {
          slug: 'config_rb_knife_optional_settings',
          type: 'Miscellaneous/Knife',
          name: 'Optional settings'
        },
        {
          slug: 'resource_common',
          name: 'About resources'
        }
      ]

      def get_name
        ADDITIONAL_URLS.each do |url|
          next unless slug == url[:slug]
          return url[:name]
        end

        css('.main-item a').map do |node|
          next unless node.attributes['href'].to_s == slug

          return node.attributes['title'].to_s
        end
        #css('h1').try(:content)
        return 'adsf'
      end

      def get_type
        ADDITIONAL_URLS.each do |url|
          next unless slug == url[:slug]
          next unless url[:type].nil?
          return url[:type]
        end

        css('.main-item a').map do |node|
          next unless node.attributes['href'].to_s == slug
          if node.ancestors('.sub-items')[0].attributes['class'].to_s.include? 'level-2'
            level2 = node.ancestors('.sub-items')[0].previous_element['title'].to_s
            level1 = node.ancestors('.sub-items')[0].ancestors('.sub-items')[0].previous_element['title'].to_s
            return "#{level1}/#{level2}"
          end

          return node.ancestors('.sub-items')[0].previous_element['title'].to_s
        end
        'Miscellaneous'
      end
    end
  end
end
