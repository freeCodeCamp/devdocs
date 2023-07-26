module Docs
  class ReactBootstrap
    class EntriesFilter < Docs::EntriesFilter
			def get_name
				header = at_css('header')
				if header
					name = header.at_css('h1').content
				else
					name = at_css('h1').content
				end
				if name.end_with?('#')
					name = name[0..-2]
				end
				name.strip
			end

      def get_type
        type = slug.split('/')[0..-2].join(': ')
        if type == ''
          type = slug.split('/').join('')
        end
        type.gsub!('-', ' ')
        type = type.split.map(&:capitalize).join(' ')
        type
      end
    end
  end
end