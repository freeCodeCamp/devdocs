module Docs
  class Cmake
    class CleanHtmlFilter < Filter
      # since each property category has its own entry redirect to that one instead
      URL_MAPPING = {
        '/manual/cmake-properties.7#properties-of-global-scope' => '/../cmake-properties-of-global-scope/',
        '/manual/cmake-properties.7#properties-on-directories' => '/../cmake-properties-on-directories/',
        '/manual/cmake-properties.7#target-properties' => '/../cmake-properties-on-targets/',
        '/manual/cmake-properties.7.html#properties-on-tests' => '/../cmake-properties-on-tests/',
        '/manual/cmake-properties.7.html#properties-on-source-files' => '/../cmake-properties-on-source-files/',
        '/manual/cmake-properties.7.html#properties-on-cache-entries' => '/../cmake-properties-on-cache-entries/',
        '/manual/cmake-properties.7.html#properties-on-installed-files' => '/../cmake-properties-on-installed-files/',
        '/manual/cmake-properties.7.html#deprecated-properties-on-directories' => '/../cmake-deprecated-properties-on-directories/',
        '/manual/cmake-properties.7.html#deprecated-properties-on-targets' => '/../cmake-deprecated-properties-on-targets/',
        '/manual/cmake-properties.7.html#deprecated-properties-on-source-files' => '/../cmake-deprecated-properties-on-source-files/'
      }

      def call
        css('.headerlink').remove
        if root_page?
          css('#release-notes').remove
          css('#index-and-search').remove
          return doc
        end
        css('.toc-backref').each do |link|
          link.replace(link.text)
        end
        css('#contents').remove

        # change urls pointing to entries which don't have a default entry
        css('a').each do |link|
          URL_MAPPING.each do |key, value|
            if link['href'].end_with? key
              link['href'] = link['href'][0..-(key.length + 1)] + value
            end
          end
        end

        doc
      end
    end
  end
end
