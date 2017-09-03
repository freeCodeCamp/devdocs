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
        if match = text.match(/\AChapter (\d+)\. (.+)\z/)
          result[:pg_chapter] = match[1].to_i
          result[:pg_chapter_name] = match[2].strip
        elsif match = text.match(/\AAppendix ([A-Z])\. (.+)\z/)
          result[:pg_appendix] = match[1]
          result[:pg_appendix_name] = match[2].strip
        end
      end
    end
  end
end
