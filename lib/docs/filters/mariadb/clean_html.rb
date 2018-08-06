require 'net/http'

module Docs
  class Mariadb
    class CleanHtmlFilter < Filter
      @@known_urls = Hash.new

      def call
        # Extract main content
        @doc = at_css('#content')

        # Remove navigation at the bottom
        css('.simple_section_nav').remove

        # Remove table of contents
        css('.table_of_contents').remove

        # Add code highlighting and remove nested tags
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'sql'
        end

        # Fix links like http://kb-mirror.mariadb.com/kb/en/bitwise-or/ to not redirect to an external page
        css('a').each do |node|
          url = node['href']

          if /^http:\/\/kb-mirror\.mariadb\.com\/kb\/en\/[^\/]+\/(#[^\/]+)?$/.match?(url)
            final_url = get_final_url(url)

            if !final_url.nil? && final_url.start_with?('/kb/en/library/documentation/')
              node['href'] = "#{'../' * subpath.count('/')}#{final_url[29..-1]}index"
            end
          end
        end

        # Remove navigation items containing only numbers
        css('.node_comments').each do |node|
          if node.content.scan(/\D/).empty?
            node.remove
          end
        end

        # Convert listings (pages like http://kb-mirror.mariadb.com/kb/en/library/documentation/sql-statements-structure/) into tables
        css('ul.listing').each do |node|
          rows = []

          node.css('li').each do |li|
            name = li.at_css('.media-heading').content
            description = li.at_css('.blurb').content
            url = li.at_css('a')['href']
            rows << "<tr><td><a href=\"#{url}\">#{name}</a></td><td>#{description}</td></tr>"
          end

          table = "<table><thead><tr><th>Title</th><th>Description</th></tr></thead><tbody>#{rows.join('')}</tbody></table>"
          node.replace(table)
        end

        doc
      end

      def get_final_url(url)
        unless @@known_urls.has_key?(url)
          @@known_urls[url] = Net::HTTP.get_response(URI(url))['location']
        end

        @@known_urls[url]
      end
    end
  end
end
