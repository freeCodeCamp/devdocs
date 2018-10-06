module Docs
  class Enzyme
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.page-inner h1').content

        if name.include?('(')
          until_parenthesis = name[0..name.index('(')]

          if until_parenthesis.include?(' ')
            until_parenthesis[0..-3]
          else
            until_parenthesis + ')'
          end
        else
          name
        end
      end

      def get_type
        active_level = at_css('.chapter.active')['data-level']

        # It's a parent level if it contains only one dot
        if active_level.count('.') == 1
          at_css('.chapter.active > a').content
        else
          parent_level = active_level[0..active_level.rindex('.') - 1]
          at_css(".chapter[data-level=\"#{parent_level}\"] > a").content
        end
      end
    end
  end
end
