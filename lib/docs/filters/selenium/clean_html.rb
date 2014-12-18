module Docs
  class Selenium
    class CleanHtmlFilter < Filter
      def call

        # remove nodes before Actions documentation
        node = css('h2:contains("Selenium Actions")')
        node.xpath('preceding-sibling::*').remove

        # remove nodes after Accessors documentation
        node = css('h2:contains("Selenium Accessors")').xpath('following-sibling::h2')
        node.xpath('following-sibling::*').remove
        node.remove

        # remove body node and untagged text
        css('body').children.each do |node|
          node.parent = node.parent.parent unless node.name == 'text'
        end
        css('body').remove

        # set anchor for internal references
        css('dt > strong').each do |node|
          anchor = Nokogiri::XML::Node.new "a", @doc
          anchor.content = node.content
          anchor['id'] = anchor.content[/\w+/].downcase
          node.content = ''
          node.name = 'h3'
          anchor.parent = node
        end

        # include arguments into colored note
        css('p:contains("Arguments")').each do |node|
          node.name = "div"
          node['class'] = "synopsis"
          node.next_element.parent = node
        end

        # fix external links
        css('a').each do |node|
          if node['href']
            unless ['actions', 'accessors'].include? node['href'][/#(.*)/, 1]
              node['href'] = Selenium.base_url + node['href']
            end
          end
        end

        doc
      end
    end
  end
end
