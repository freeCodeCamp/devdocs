module Docs
  class TclTk
    class CleanHtmlFilter < Filter
      def call
	# Page Title
        css('h2').remove
	# Navigation
        css('h3:first-child').remove
	# restore breaks in copyright
        txt = at_css('div.copy').content
        at_css('div.copy').content = txt.gsub! /.Copyright/, "\n\\0"

        file = result[:path].split('/')[-1]
        re = Regexp.new('^' + Regexp.escape(file) + '(#.*)$')
        css('a[name]').each do |node|
          if node['href'] then
            # useless name
            node.remove_attribute 'name'
            # make fragments relativ
            if node['href'].match re then
              node['href'] = node['href'].sub re, '\\1'
            end
          else
            # move name to id
            node.parent['id'] = node['name']
            node.parent.content = node.content
          end
        end

	# remove keywords headline
	css('h3').each do |node|
          if node.content == 'KEYWORDS' then
            node.remove
          end
	end
        # remove keywords links
	css('a').each do |node|
          attr = node.attribute('href')
	  if attr && attr.value.match(/\/Keywords\//) then
            # the ','
            if node.next_sibling then
              node.next_sibling.remove
            end
            node.remove
          end
	end

        doc
      end
    end
  end
end
