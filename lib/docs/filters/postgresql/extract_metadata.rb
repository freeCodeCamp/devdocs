module Docs
  class Postgresql
    class ExtractMetadataFilter < Filter
      def call
        extract_up_path
        extract_chapter
        doc
      end

      def extract_up_path
        if node = at_css('.NAVHEADER a[accesskey="U"]')
          result[:pg_up_path] = node['href']
        end
      end

      def extract_chapter
        return unless text = at_css('.NAVHEADER td[align="center"]').content
        return unless match = text.match(/\AChapter (\d+)\. (.+)\z/)
        result[:pg_chapter] = match[1].to_i
        result[:pg_chapter_name] = match[2]
      end
    end
  end
end
